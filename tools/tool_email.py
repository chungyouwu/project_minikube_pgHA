import smtplib
from email.mime.text import MIMEText
import configparser

config = configparser.ConfigParser()
with open('email.ini', 'r', encoding='utf-8') as f:
    config.read_file(f) 

smtp_user = config['smtp']['user']
smtp_password = config['smtp']['password']
smtp_server = config['smtp']['server']
smtp_port = config['smtp']['port']

msg = MIMEText('Python 寄信功能測試，請勿回覆!', 'plain', 'utf-8') # 信件內容
msg['Subject'] = 'Do you see me?'    # 郵件標題
msg['From'] = 'WorkingBuffer'        # 寄件者名
msg['To'] = 'chungyou'               # 收件者名
msg['Cc'] = 'abel@navibio.com.tw'    # 副本收件人信箱(需要再測試)
message = msg.as_string()

try:
    with smtplib.SMTP_SSL(smtp_server, smtp_port) as server:
      
        server.login(smtp_user, smtp_password)
        server.sendmail(smtp_user,'chungyou0118@gmail.com', message)
    print('Email sent successfully')
except Exception as e:
    print('Email sent failed')