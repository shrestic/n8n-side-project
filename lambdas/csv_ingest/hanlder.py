import os
import logging
import csv
import io
import json
import boto3
import psycopg2
import psycopg2.extras
from urllib.request import Request, urlopen

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

S3 = boto3.client("s3")
N8N_WEBHOOK_BASE = os.environ.get("N8N_WEBHOOK_BASE_URL")
N8N_WEBHOOK_KEY = os.environ.get("N8N_WEBHOOK_KEY")

RDS_HOST = os.environ.get("RDS_HOST")
RDS_PORT = int(os.environ.get("RDS_PORT", 5432))
RDS_DB = os.environ.get("RDS_DB")
RDS_USER = os.environ.get("RDS_USER")
RDS_PASSWORD = os.environ.get("RDS_PASSWORD")

INSERT_BATCH = 200

def get_db_conn():
    return psycopg2.connect(
        host=RDS_HOST,
        port=RDS_PORT,
        dbname=RDS_DB,
        user=RDS_USER,
        password=RDS_PASSWORD,
        connect_timeout=10
    )

def call_n8n_webhook(s3_key):
    if not N8N_WEBHOOK_BASE or not N8N_WEBHOOK_KEY:
        LOG.warning("N8N webhook not configured; skipping webhook call.")
        return
    endpoint = f"{N8N_WEBHOOK_BASE}/webhook/match-start?key={N8N_WEBHOOK_KEY}"
    data = json.dumps({"s3_key": s3_key}).encode("utf-8")
    req = Request(endpoint, data=data, headers={"Content-Type":"application/json"})
    try:
        resp = urlopen(req, timeout=15)
        LOG.info("n8n webhook response: %s", resp.getcode())
    except Exception as e:
        LOG.exception("Failed to call n8n webhook: %s", e)

def parse_and_insert(bucket, key):
    obj = S3.get_object(Bucket=bucket, Key=key)
    body = obj["Body"].read()
    text = body.decode("utf-8", errors="replace")
    reader = csv.DictReader(io.StringIO(text))
    rows = []
    for r in reader:
        # Normalize keys (lowercase)
        rows.append({
            "user_id": r.get("user_id") or r.get("id") or r.get("uid"),
            "email": r.get("email"),
            "monthly_income": safe_num(r.get("monthly_income")),
            "credit_score": safe_int(r.get("credit_score")),
            "employment_status": r.get("employment_status"),
            "age": safe_int(r.get("age"))
        })
        if len(rows) >= INSERT_BATCH:
            batch_insert(rows)
            rows = []
    if rows:
        batch_insert(rows)

def batch_insert(rows):
    insert_query = """
    INSERT INTO users (user_id, email, monthly_income, credit_score, employment_status, age)
    VALUES %s
    ON CONFLICT (user_id) DO UPDATE SET
      email = EXCLUDED.email,
      monthly_income = EXCLUDED.monthly_income,
      credit_score = EXCLUDED.credit_score,
      employment_status = EXCLUDED.employment_status,
      age = EXCLUDED.age
    """
    values = [
        (r["user_id"], r["email"], r["monthly_income"], r["credit_score"], r["employment_status"], r["age"])
        for r in rows if r["user_id"] and r["email"]
    ]
    if not values:
        return
    conn = get_db_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                psycopg2.extras.execute_values(cur, insert_query, values, template=None, page_size=100)
        LOG.info("Inserted %d rows", len(values))
    finally:
        conn.close()

def safe_int(v):
    try:
        return int(float(v))
    except Exception:
        return None

def safe_num(v):
    try:
        return float(v)
    except Exception:
        return None

def handler(event, context):
    """
    S3 event handler
    """
    try:
        # event may contain multiple Records
        records = event.get("Records", [])
        for rec in records:
            s3_info = rec.get("s3", {})
            bucket = s3_info.get("bucket", {}).get("name")
            key = s3_info.get("object", {}).get("key")
            LOG.info("Processing S3 object: %s/%s", bucket, key)
            parse_and_insert(bucket, key)
            # call n8n webhook to trigger matching workflow
            call_n8n_webhook(key)
        return {"statusCode": 200, "body": json.dumps({"processed": len(records)})}
    except Exception as e:
        LOG.exception("Error processing CSV")
        raise
