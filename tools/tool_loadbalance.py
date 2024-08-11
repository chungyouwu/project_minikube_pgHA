import psycopg2

# 連接到你的 PostgreSQL 資料庫
conn = psycopg2.connect(
    dbname='postgres',
    user='postgres',
    password='0000',
    host='localhost',
    port='8888'
)

# 創建一個游標對象
cur = conn.cursor()

# 執行 SELECT 查詢 100 次
for _ in range(100):
    cur.execute('SELECT * FROM account_information')

# 關閉游標和連接
cur.close()
conn.close()
