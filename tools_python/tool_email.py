import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import configparser



def send_email(subject, body, to_email):
    # 讀取配置文件
    config = configparser.ConfigParser()  # 避免在程式碼中出現敏感資訊
    config.read('email.ini')
    smtp_user = config['smtp']['user']
    smtp_password = config['smtp']['password']

    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = smtp_user
    msg['To'] = to_email

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(smtp_user, smtp_password)
            server.sendmail(smtp_user, to_email, msg.as_string())
        print(f"Email sent to {to_email}")
    except Exception as e:
        print(f"Failed to send email: {e}")
    finally:
        server.quit()

# 設定條件變數，假設在這裡檢測到連線數大於2
some_condition_detected = True

if some_condition_detected:
    send_email("PostgreSQL 警報", "查詢延遲過高，請立即檢查。", "dba_team@example.com")













