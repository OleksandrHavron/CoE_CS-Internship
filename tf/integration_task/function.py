import json
import os
import socket

import boto3
import requests


def lambda_handler(event, context):
    count = os.environ["count"]
    endpoint = "ohavron-ocg1.link"
    IP = socket.gethostbyname(endpoint)
    es_endpoint = "elasticsearch.ohavron-ocg1.link"

    try:
        es_response = requests.get(
            f"http://{es_endpoint}:9200/_cluster/health?pretty")
        print("elasticsearch cluster: ", es_response.text)
        es_health = json.loads(es_response.text)
        if es_health["status"] == "green" and es_health["number_of_nodes"] == 6:
            es_status = 1
        else:
            es_status = 0

        print("elasticsearch status: ", es_status)
        cloudwatch = boto3.client('cloudwatch')
        cloudwatch.put_metric_data(
            MetricData=[
                {
                    'MetricName': 'cluster_health',
                    'Dimensions': [
                        {
                            'Name': 'Cluster name',
                            'Value': es_health["cluster_name"]
                        },
                    ],
                    'Unit': 'None',
                    'Value': es_status
                },
            ],
            Namespace='ES_CLUSTER'
        )

    except requests.ConnectionError as e:
        es_status = 0
        print("elasticsearch status: ", es_status)
        cloudwatch = boto3.client('cloudwatch')
        cloudwatch.put_metric_data(
            MetricData=[
                {
                    'MetricName': 'cluster_health',
                    'Dimensions': [
                        {
                            'Name': 'Cluster name',
                            'Value': es_health["cluster_name"]
                        },
                    ],
                    'Unit': 'None',
                    'Value': es_status
                },
            ],
            Namespace='ES_CLUSTER'
        )

    try:
        response = requests.get(f"https://{endpoint}/")
        print("Wordpress response code: ", response.status_code)
        if response.status_code >= 200 and response.status_code < 400:
            print("Wordpress status: healthy")
            os.environ["count"] = "0"
        else:
            print("Wordpress status: unhealthy")
            count = str(int(count)+1)
            os.environ["count"] = count
            print("Count of failed checks: ", count)

    except requests.ConnectionError as e:
        print("Failed to establsih connection")
        print(e)
        count = str(int(count)+1)
        os.environ["count"] = count
        print("Count of failed checks: ", count)

    # Send notification
    if count == "3":
        import smtplib
        from email.mime.multipart import MIMEMultipart
        from email.mime.text import MIMEText
        mail_content = f'''
Hello,
There are three failed health checks in a row at the endpoint({endpoint})
Endpoint = {endpoint}
IP = {IP}'''
        # The mail addresses and password
        sender_address = os.environ["email_address"]
        sender_pass = os.environ["email_pass"]
        receiver_address = os.environ["email_address"]
        # Setup the MIME
        message = MIMEMultipart()
        message['From'] = sender_address
        message['To'] = receiver_address
        # The subject line
        message['Subject'] = 'Health check failed notification.'
        # The body and the attachments for the mail
        message.attach(MIMEText(mail_content, 'plain'))
        # Create SMTP session for sending the mail
        session = smtplib.SMTP('smtp.gmail.com', 587)  # use gmail with port
        session.starttls()  # enable security
        # login with mail_id and password
        session.login(sender_address, sender_pass)
        text = message.as_string()
        session.sendmail(sender_address, receiver_address, text)
        session.quit()
        print('Mail Sent')
        os.environ["count"] = "0"

    return {
        'statusCode': response.status_code,
        'endpoint': endpoint,
        'IP': IP,
        'es endpoint': es_endpoint,
        'es status': es_status
    }
