"""Create the asset bucket and make its objects publicly readable (idempotent).

stac-browser shows thumbnails straight from the object store, so anonymous GET must work.
Reads the same S3_* and AWS_* variables as eo_ingest; `make up` pins them to the local store.
"""

import json
import os

import boto3

bucket = os.environ["S3_BUCKET"]
s3 = boto3.client(
    "s3",
    endpoint_url=os.environ["S3_ENDPOINT_URL"],
    region_name=os.environ.get("AWS_REGION", "us-east-1"),
)

if bucket not in {b["Name"] for b in s3.list_buckets()["Buckets"]}:
    s3.create_bucket(Bucket=bucket)
s3.put_bucket_policy(
    Bucket=bucket,
    Policy=json.dumps(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"AWS": ["*"]},
                    "Action": ["s3:GetObject"],
                    "Resource": [f"arn:aws:s3:::{bucket}/*"],
                }
            ],
        }
    ),
)
print(f"bucket {bucket}: ready, objects publicly readable")
