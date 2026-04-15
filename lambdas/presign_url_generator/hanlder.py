import os
import json
import logging
import boto3
from urllib.parse import quote_plus

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

S3_BUCKET = os.environ.get("S3_BUCKET")

s3 = boto3.client("s3")

def handler(event, context):
    """
    Lambda HTTP handler that returns a presigned PUT URL to upload CSV directly to S3.
    Expects a query string param: filename (e.g. users.csv)
    """
    try:
        # For HTTP API (API Gateway v2), query params available differently depending on invocation
        qs = event.get("queryStringParameters") or {}
        filename = qs.get("filename") or qs.get("file") or "users.csv"
        key = f"uploads/{quote_plus(filename)}"
        url = s3.generate_presigned_url(
            ClientMethod="put_object",
            Params={"Bucket": S3_BUCKET, "Key": key, "ContentType": "text/csv"},
            ExpiresIn=900
        )
        body = {"upload_url": url, "s3_key": key}
        return {"statusCode": 200, "body": json.dumps(body)}
    except Exception as e:
        LOG.exception("Error generating presign")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
