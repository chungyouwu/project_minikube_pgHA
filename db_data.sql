-- 生成銀行分行資料(tatao_funds 為假設 不能核銷)
INSERT INTO bankbranches (bank_region, bank_name, account_num, total_funds)
SELECT 'north', 
       'North Branch ' || i, 
       100, 
       random() * 10000000
FROM generate_series(1, 10) i;


INSERT INTO bankbranches (bank_region, bank_name, account_num, total_funds)
SELECT 'south', 
       'South Branch ' || i, 
       100, 
       random() * 10000000
FROM generate_series(1, 10) i;



-- 生成用戶資訊
INSERT INTO user_information (name, gender, phone, email)
SELECT 'User' || i, 
       'M', 
       '123-456-7890', 
       'user' || i || '@example.com' 
FROM generate_series(1, 1000) i;


-- 生成帳號資訊
INSERT INTO account_information (user_id, bank_id, bank_region, balance, opendate)
SELECT i,
       b,
       (CASE WHEN b <= 10 THEN 'north' ELSE 'south' END)::bank_region,
       random() * 10000,
       CURRENT_DATE - (random() * 365)::int
FROM (
    SELECT i, FLOOR(random() * 20 + 1) AS b
    FROM generate_series(1, 1000) i
) subquery;



-- 生成帳號密碼
INSERT INTO account_credentials (account_id, password)
SELECT account_id, 
       LPAD(FLOOR(random()*10000)::text,4,'0')
FROM account_information;


-- 生成市場調查資料
INSERT INTO marketsurvey (survey_title, survey_des, survey_response)
SELECT 'Survey ' || i, 'Description ' || i, jsonb_build_object('response', 'response' || i)
FROM generate_series(1, 10) i;









-- 簡單數據
insert into bankbranches(bank_Region, bank_name, account_num, total_funds) values('south','Kaohsiung',99, 1000000);
insert into bankbranches(bank_Region, bank_name, account_num, total_funds) values('north','Taoyuan',199, 1000000);

insert into user_information(name,gender, phone, email) values('abel','M','972XXX296','abel@gmail.com');
insert into user_information(name,gender, phone, email) values('shelly','F','980XXX422','shelly@gmail.com');
insert into user_information(name,gender, phone, email) values('chung','M','8XXXXXXXX','chung@gmail.com');

insert into account_information(user_id, bank_id, bank_region, balance, opendate) values(0,1,'south',1000,'2024-01-18');
insert into account_information(user_id, bank_id, bank_region, balance, opendate) values(1,2,'north',1000,'2024-07-23');

insert into account_credentials(account_id, password) values(0,'1111');
insert into account_credentials(account_id, password) values(1,'2222');

INSERT INTO marketsurvey(survey_title,survey_des,survey_response) VALUES(
    'Customer Satisfaction Survey',
    'Please provide your feedback on our service',
    '{"Q0:Survey date":"2024-07-23",
      "Q1:What is your bank account number?":"1234567890",
      "Q2: satisfaction":{"service":"8",
                          "efficiency":"6",
                          "quality":"7"}
}');