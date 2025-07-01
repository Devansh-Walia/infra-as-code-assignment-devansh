import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Simple Lambda function that returns 'Hello world' for Milestone 1
    """
    logger.info("Hello World Lambda function invoked")
    logger.info(f"Event: {json.dumps(event)}")
    
    try:
        # Simple response for Milestone 1
        response = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "Hello world"
            })
        }
        
        logger.info("Successfully returning Hello world response")
        return response
        
    except Exception as e:
        logger.error(f"Error in Lambda function: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "message": "Internal server error"
            })
        }
