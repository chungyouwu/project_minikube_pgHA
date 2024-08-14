-- 模擬銀行資料庫 #enum type

CREATE TYPE bank_region AS ENUM('north','south','unknown');
CREATE TYPE payby AS ENUM('credit card','debit card', 'cash', 'transfer');



-- 銀行分行 (主鍵需包含分區鍵) #partition
CREATE TABLE bankbranches (
    bank_id SERIAL ,
    bank_region bank_region NOT NULL,
    bank_name VARCHAR(20) NOT NULL,
    account_num INT NOT NULL,
    total_funds NUMERIC(15,2) NOT NULL,
    PRIMARY KEY (bank_id, bank_region)  
) PARTITION BY LIST (bank_region);


CREATE TABLE bankbranches_north PARTITION OF bankbranches FOR VALUES IN ('north');
CREATE TABLE bankbranches_south PARTITION OF bankbranches FOR VALUES IN('south');
CREATE TABLE bankbranches_default PARTITION OF bankbranches DEFAULT;



-- 用戶資訊
CREATE TABLE user_information (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender CHAR(1),
    phone VARCHAR(15),
    email VARCHAR(100)
);


-- 帳號資訊(需使用複合外鍵,因 bankbranches 是複合主鍵)
CREATE TABLE account_information (
    account_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES user_information(user_id),
    bank_id INT,
    bank_region bank_region,
    balance DECIMAL(15, 2),
    opendate DATE,
    FOREIGN KEY (bank_id, bank_region) 
    REFERENCES bankbranches (bank_id, bank_region) MATCH FULL 
);  


CREATE INDEX account_index 
ON account_information(account_id) 
INCLUDE (balance);


CREATE VIEW account_view AS 
SELECT ui.name, bb.bank_name, ai.balance 
FROM user_information ui 
JOIN account_information ai ON ai.user_id = ui.user_id
JOIN bankbranches bb ON bb.bank_id = ai.bank_id;




-- 帳號密碼 #RLS, policy, trigger
CREATE TABLE account_credentials (
    account_id INT REFERENCES account_information(account_id),    
    password VARCHAR(50) NOT NULL
);


ALTER TABLE account_credentials ENABLE ROW LEVEL SECURITY;

CREATE POLICY account_cred_policy
ON account_credentials
FOR ALL
USING( current_user = 'postgres');



CREATE TABLE account_cred_his(
    his_id serial primary key,
    his_time timestamp default current_timestamp,
    old_password VARCHAR(50),
    new_password VARCHAR(50)
);



CREATE FUNCTION account_cred_tg_fn()
RETURNS trigger AS $$
BEGIN
INSERT INTO account_cred_his(old_password, new_password) 
VALUES(OLD.password, NEW.password);
RETURN NEW;
END $$
LANGUAGE plpgsql;


CREATE TRIGGER account_cred_tg
AFTER UPDATE OF password ON account_credentials
FOR EACH ROW
EXECUTE FUNCTION account_cred_tg_fn();





-- 市場調查 #jsonb type
CREATE TABLE marketsurvey(
    survey_id serial primary key,    
    survey_title varchar(30) not null,
    survey_des varchar(200),
    survey_response jsonb
); 






-- 交易功能&歷史紀錄 #procedure
CREATE TABLE account_info_trans_history (
    trans_id SERIAL PRIMARY KEY,
    trans_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trans_sourceid int REFERENCES account_information(account_id) NOT NULL,     
    trans_amount NUMERIC(15, 2) NOT NULL,
    trans_targetid int REFERENCES account_information(account_id) NOT NULL,
    trans_reason varchar(30),
    trans_method payby
);


-- default 出現後, 下方參數也都要有預設值 
CREATE PROCEDURE transfer_funds(m_from int, 
                      m_to int,
                      amount numeric(15,2),
                      reason varchar(30) default null,  
                      method payby default 'cash')
AS $$
DECLARE
account_num int;
BEGIN
  select count(*) into account_num from account_information where account_id in (m_from, m_to);
  if account_num = 2 then 
    raise notice 'both account exist, transaction starting...';
    update account_information set balance=balance - amount where account_id = m_from;
    update account_information set balance=balance + amount where account_id = m_to;
    insert into account_info_trans_history(trans_sourceid,trans_amount,trans_targetid, trans_reason, trans_method) 
    values(m_from,amount,m_to, reason, method);
        
  else 
    raise exception 'One of the accounts does not exist';
    
  end if;
END$$
LANGUAGE plpgsql;



-- 新增角色
CREATE ROLE chung WITH LOGIN PASSWORD '0000';
GRANT USAGE, CREATE ON SCHEMA public TO chung;
GRANT ALL ON ALL TABLES IN SCHEMA public TO chung;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO chung;

CREATE ROLE abel WITH LOGIN PASSWORD '0000';
GRANT USAGE, CREATE ON SCHEMA public TO abel;
GRANT ALL ON ALL TABLES IN SCHEMA public TO abel;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO abel;



-- 新增 extension
CREATE extension pg_stat_statements;
CREATE EXTENSION pg_buffercache;


