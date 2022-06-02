import json
import socket
import requests
import os

def lambda_handler(event, context):

    count = os.environ["count"]
    endpoint = "ohavron-ocg1.link"
    IP = socket.gethostbyname(endpoint)
    
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
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }