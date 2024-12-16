import pytest
from unittest.mock import patch, MagicMock
from unittest.mock import Mock
import csv
import os
from src.lambda_function import lambda_handler, transform_csv, upload_with_kms, notify_via_sns
from botocore.exceptions import ClientError


@pytest.fixture
def mock_environment_variables(monkeypatch):
    monkeypatch.setenv('SNS_TOPIC_ARN', 'arn:aws:sns:us-east-1:123456789012:my-topic')
    monkeypatch.setenv('KMS_ARN', 'arn:aws:kms:us-east-1:123456789012:key/my-key')
    monkeypatch.setenv('TARGET_BUCKET', 'my-target-bucket')


@pytest.fixture
def mock_s3_client(mocker):
    # Patch boto3.client() to return a mock object
    mock_s3 = mocker.patch('boto3.client')
    mock_s3_instance = mock_s3.return_value
    
    # Mock methods on the S3 client (download_file, put_object)
    mock_s3_instance.download_file = MagicMock()
    mock_s3_instance.put_object = MagicMock()
    
    return mock_s3_instance


@pytest.fixture
def mock_sns_client(mocker):
    # Patch boto3.client() to return a mock SNS client
    mock_sns = mocker.patch('boto3.client')
    mock_sns_instance = mock_sns.return_value
    
    # Mock methods on the SNS client (publish)
    mock_sns_instance.publish = MagicMock()
    
    return mock_sns_instance


@pytest.fixture
def mock_download_file(mocker):
    # Return the mock method for download_file
    return mocker.patch('boto3.client().download_file')


@pytest.fixture
def mock_put_object(mocker):
    # Return the mock method for put_object
    return mocker.patch('boto3.client().put_object')


@pytest.fixture
def mock_publish(mocker):
    # Return the mock method for publish
    return mocker.patch('boto3.client().publish')


def test_lambda_handler_success(mock_environment_variables, mock_s3_client, mock_sns_client, mock_download_file,
                                 mock_put_object, mock_publish, mocker):
    # Mock the S3 download to simulate a file in S3
    mock_s3_client.download_file.return_value = None

    # Mock file processing
    mocker.patch('src.lambda_function.transform_csv', return_value=None)

    # Mock upload with KMS encryption
    mock_s3_client.put_object.return_value = None

    # Mock the SNS publish to prevent actual calls
    mock_publish.return_value = None

    event = {
        'Records': [{
            's3': {
                'bucket': {'name': 'my-source-bucket'},
                'object': {'key': 'test.csv'}
            }
        }]
    }
    context = {}

    lambda_handler(event, context)

    # Assert the correct calls to S3 and SNS
    mock_s3_client.download_file.assert_called_once_with('my-source-bucket', 'test.csv', './test.csv')
    mock_s3_client.put_object.assert_called_once_with(
        Bucket='my-target-bucket',
        Key='processed_test.csv',
        Body=MagicMock(),
        ServerSideEncryption='aws:kms',
        SSEKMSKeyId='arn:aws:kms:us-east-1:123456789012:key/my-key'
    )
    mock_publish.assert_called_once_with(
        TopicArn='arn:aws:sns:us-east-1:123456789012:my-topic',
        Subject='CSV Processing Successful',
        Message='File test.csv successfully processed and uploaded as processed_test.csv.'
    )


def test_lambda_handler_failure(mock_environment_variables, mock_s3_client, mock_sns_client, mock_download_file,
                                mock_put_object, mock_publish, mocker):
    # Simulate failure in file processing
    mock_s3_client.download_file.side_effect = ClientError({'Error': {'Code': 'NoSuchKey'}}, 'DownloadFile')

    event = {
        'Records': [{
            's3': {
                'bucket': {'name': 'my-source-bucket'},
                'object': {'key': 'nonexistent.csv'}
            }
        }]
    }
    context = {}

    with pytest.raises(ClientError):
        lambda_handler(event, context)

    # Assert SNS failure notification was triggered
    mock_publish.assert_called_once_with(
        TopicArn='arn:aws:sns:us-east-1:123456789012:my-topic',
        Subject='CSV Processing Failed',
        Message='Error processing file nonexistent.csv: An error occurred (NoSuchKey) when calling the DownloadFile operation: '
                'The specified key does not exist.'
    )


def test_transform_csv():
    input_file = './sample_test.csv'
    output_file = '/tmp/output.csv'
    # Ensure the /tmp directory exists
    os.makedirs(os.path.dirname(input_file), exist_ok=True)
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    # Create the input file
    with open(input_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['name', 'age'])
        writer.writerow(['john', '25'])
        writer.writerow(['alice', '30'])

    transform_csv(input_file, output_file)

    with open(output_file, 'r', newline='') as f:
        reader = csv.reader(f)
        rows = list(reader)

    assert rows == [['NAME', 'AGE'], ['JOHN', '25'], ['ALICE', '30']]


def test_upload_with_kms(mock_s3_client, mock_put_object):
    file_path = '/tmp/test_file.csv'
    mock_s3_client.put_object.return_value = None
    upload_with_kms('my-target-bucket', 'processed_test.csv', file_path)

    mock_put_object.assert_called_once_with(
        Bucket='my-target-bucket',
        Key='processed_test.csv',
        Body=MagicMock(),
        ServerSideEncryption='aws:kms',
        SSEKMSKeyId='arn:aws:kms:us-east-1:123456789012:key/my-key'
    )


def test_notify_via_sns_success(mock_sns_client, mock_publish):
    message = "Test message"
    notify_via_sns(message)

    mock_publish.assert_called_once_with(
        TopicArn='arn:aws:sns:us-east-1:123456789012:my-topic',
        Subject='CSV Processing Successful',
        Message=message
    )


def test_notify_via_sns_failure(mock_sns_client, mock_publish):
    message = "Error message"
    notify_via_sns(message, success=False)

    mock_publish.assert_called_once_with(
        TopicArn='arn:aws:sns:us-east-1:123456789012:my-topic',
        Subject='CSV Processing Failed',
        Message=message
    )
