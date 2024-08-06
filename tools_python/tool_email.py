import smtplib
from email.mime.text import MIMEText

def send_email(subject, body, to_email):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = "monitoring@example.com"
    msg['To'] = to_email

    with smtplib.SMTP('smtp.example.com') as server:
        server.login("your_email@example.com", "your_password")
        server.sendmail("monitoring@example.com", to_email, msg.as_string())

# 假設在這裡檢測到異常
if some_condition_detected:
    send_email("PostgreSQL 警報", "查詢延遲過高，請立即檢查。", "dba_team@example.com")