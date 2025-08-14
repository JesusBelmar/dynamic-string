import os
import boto3
from datetime import datetime
from jinja2 import Environment, FileSystemLoader
import time

# Environment variables
SSM_PARAM_NAME = os.environ.get('SSM_PARAM_NAME', '/challenge/dynamic_string')
REGION = os.environ.get('AWS_REGION', 'us-east-1')

# Cache for SSM parameter
CACHE = {'value': None, 'timestamp': 0, 'ttl': 60}  # Cache for 60 seconds

def get_ssm_parameter():
    """Fetch parameter from SSM with caching"""
    current_time = time.time()
    if CACHE['value'] and (current_time - CACHE['timestamp']) < CACHE['ttl']:
        print("Using cached SSM parameter")
        return CACHE['value']
    
    try:
        ssm = boto3.client('ssm', region_name=REGION)
        response = ssm.get_parameter(Name=SSM_PARAM_NAME, WithDecryption=False)
        CACHE['value'] = response['Parameter']['Value']
        CACHE['timestamp'] = current_time
        return CACHE['value']
    except Exception as e:
        print(f"Error fetching SSM parameter: {str(e)}")
        return "default-value"

def handler(event, context):
    """Handler for Lambda@Edge"""
    # Load template using Jinja2
    try:
        env = Environment(loader=FileSystemLoader('/var/task/templates'))
        template = env.get_template('index.html')
    except Exception as e:
        print(f"Error loading template: {str(e)}")
        return {
            'status': '500',
            'headers': {'content-type': [{'key': 'Content-Type', 'value': 'text/html'}]},
            'body': '<h1>Error loading template</h1>'
        }

    # Render template with dynamic value
    dynamic_value = get_ssm_parameter()
    html_response = template.render(
        dynamic_value=dynamic_value,
        timestamp=datetime.utcnow().isoformat()
    )

    return {
        'status': '200',
        'headers': {
            'content-type': [{'key': 'Content-Type', 'value': 'text/html'}],
            'cache-control': [{'key': 'Cache-Control', 'value': 'no-cache'}]
        },
        'body': html_response
    }