import boto3
import csv
import os
from botocore.exceptions import ClientError

# AWS Clients
s3 = boto3.client('s3', 'us-east-1')
sns_client = boto3.client('sns', 'us-east-1')

# Environment Variables
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:123456789012:my-topic"
KMS_ARN = "arn:aws:kms:us-east-1:123456789012:key/my-key"
TARGET_BUCKET = "my-target-bucket"


def lambda_handler(event, context):
    try:
        # Get bucket and file details from event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        object_key = event['Records'][0]['s3']['object']['key']

        # Temporary file paths
        local_file = f'/tmp/{object_key}'
        transformed_file = '/tmp/transformed.csv'

        # Download file from S3
        print("Downloading file from S3...")
        s3.download_file(bucket_name, object_key, local_file)

        # Process the CSV
        print("Processing CSV...")
        transform_csv(local_file, transformed_file)

        # Upload processed file to target bucket with KMS encryption
        print("Uploading processed file...")
        processed_key = f'processed_{object_key}'
        upload_with_kms(target_bucket=TARGET_BUCKET, object_key=processed_key, file_path=transformed_file)

        # Notify success via SNS
        notify_via_sns(f"File {object_key} successfully processed and uploaded as {processed_key}.")

    except Exception as e:
        # Notify failure via SNS
        error_message = f"Error processing file {object_key}: {str(e)}"
        print(error_message)
        notify_via_sns(error_message, success=False)
        raise


def transform_csv(input_file, output_file):
    """
    Transforms the CSV file: Uppercases all columns.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        for row in reader:
            # Example transformation: Uppercase all fields
            writer.writerow([col.upper() for col in row])


def upload_with_kms(target_bucket, object_key, file_path):
    """
    Uploads a file to S3 with KMS encryption enabled.
    """
    with open(file_path, 'rb') as data:
        s3.put_object(
            Bucket=target_bucket,
            Key=object_key,
            Body=data,
            ServerSideEncryption='aws:kms',
            SSEKMSKeyId=KMS_ARN  
        )
        print(f"File uploaded to {target_bucket}/{object_key} with KMS encryption.")


def notify_via_sns(message, success=True):
    """
    Sends a notification via SNS.
    """
    subject = "CSV Processing Successful" if success else "CSV Processing Failed"
    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=subject,
        Message=message
    )
    print(f"SNS Notification sent: {subject}")
