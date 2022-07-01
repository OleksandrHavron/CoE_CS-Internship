import pymysql.cursors
import boto3

s3 = boto3.resource(
    service_name='s3',
)
obj = s3.Bucket("ebs-bucket2").Object('rds_user-creds').get()

creds = obj["Body"].read().decode().split("\n")

connection = pymysql.connect(host=creds[2],
                             user=creds[1],
                             password=creds[0],
                             cursorclass=pymysql.cursors.DictCursor)

with connection:
    with connection.cursor() as cursor:
        sql = "DO SLEEP(150);"
        cursor.execute(sql)
