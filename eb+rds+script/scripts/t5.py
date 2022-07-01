import pymysql.cursors
import boto3

s3 = boto3.resource(
    service_name='s3',
)
obj = s3.Bucket("ebs-bucket2").Object('rds-creds').get()

creds = obj["Body"].read().decode().split("\n")

connection = pymysql.connect(host=creds[2],
                             user=creds[1],
                             password=creds[0],
                             database='information_schema',
                             cursorclass=pymysql.cursors.DictCursor)

with connection:
    with connection.cursor() as cursor:
        sql = "select ID from PROCESSLIST where COMMAND=\"Query\" and TIME>10;"
        cursor.execute(sql)
        result = cursor.fetchall()
        print(result)
    with connection.cursor() as cursor:
        for i in result:
            sql = "CALL mysql.rds_kill(%s);"
            cursor.execute(sql, i["ID"])
            print(i["ID"], " KILLED")
