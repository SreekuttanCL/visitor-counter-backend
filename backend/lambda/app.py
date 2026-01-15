import json
import boto3
from decimal import Decimal

# DynamoDB table
TABLE_NAME = "visitor-counter"

# Initialize DynamoDB
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print("CI/CD test")

    try:
        # Increment visitor count safely
        response = table.update_item(
            Key={"id": "visitor_count"},
            UpdateExpression="SET #c = if_not_exists(#c, :start) + :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": 1, ":start": 0},
            ReturnValues="UPDATED_NEW"
        )

        count = response["Attributes"]["count"]

        # Convert Decimal to int
        if isinstance(count, Decimal):
            count = int(count)

        # Proper Lambda Proxy Response
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
		"Cache-Control": "no-cache"
            },
            "body": json.dumps({"visitors": count})
        }

    except Exception as e:
        # Log the error for debugging
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }

