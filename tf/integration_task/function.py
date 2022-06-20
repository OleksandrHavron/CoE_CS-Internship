import json
import socket
import requests
import os
import boto3


def lambda_handler(event, context):


    count = os.environ["count"]
    endpoint = "ohavron-ocg1.link"
    IP = socket.gethostbyname(endpoint)
    es_endpoint = "elasticsearch.ohavron-ocg1.link"
    
    es_response = requests.get(f"http://{es_endpoint}:9200/_cluster/health?pretty")
    
    print(es_response.text)
    
    es_health = json.loads(es_response.text)
    
    if es_health["status"] == "green" and es_health["number_of_nodes"]:
        es_status = 1
    
    print(es_health["status"])
    
    cloudwatch = boto3.client('cloudwatch')
    response321 = cloudwatch.put_metric_data(
        MetricData = [
            {
                'MetricName': 'ES_Health',
                'Dimensions': [
                    # {
                    #     'Name': 'PURCHASES_SERVICE',
                    #     'Value': 'CoolService'
                    # },
                    {
                        'Name': 'APP_VERSION',
                        'Value': '1.0'
                    },
                ],
                'Unit': 'None',
                'Value': es_status
            },
        ],
        Namespace = 'ES_CLUSTER'
    )
    try:
        response = requests.get(f"https://{endpoint}/")
    
        print(response.status_code)
    
        if response.status_code >= 200 and response.status_code < 400:
            print("healthy")
            os.environ["count"] = "0"
        else:
            print("unhealthy")
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
        #The mail addresses and password
        sender_address = os.environ["email_address"]
        sender_pass = os.environ["email_pass"]
        receiver_address = os.environ["email_address"]
        #Setup the MIME
        message = MIMEMultipart()
        message['From'] = sender_address
        message['To'] = receiver_address
        message['Subject'] = 'Health check failed notification.'   #The subject line
        #The body and the attachments for the mail
        message.attach(MIMEText(mail_content, 'plain'))
        #Create SMTP session for sending the mail
        session = smtplib.SMTP('smtp.gmail.com', 587) #use gmail with port
        session.starttls() #enable security
        session.login(sender_address, sender_pass) #login with mail_id and password
        text = message.as_string()
        session.sendmail(sender_address, receiver_address, text)
        session.quit()
        print('Mail Sent')
        os.environ["count"] = "0"

    return {
        'statusCode': response.status_code,
        'endpoint': endpoint,
        'IP': IP
    }