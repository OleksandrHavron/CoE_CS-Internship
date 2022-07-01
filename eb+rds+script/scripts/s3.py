import boto3

s3 = boto3.resource(
    service_name='s3',
)
obj = s3.Bucket("ebs-bucket2").Object('rds-creds').get()

creds = obj["Body"].read().decode().split("\n")

print(creds)