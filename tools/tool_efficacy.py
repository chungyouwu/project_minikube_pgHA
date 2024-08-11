
import psycopg2
import time

def collect_metrics():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="0000",
        host="localhost",
        port="8888"
    )
    cur = conn.cursor()

    # 查詢數據庫效能指標
    query = """SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit 
               FROM pg_stat_database;"""

    cur.execute(query)
    metrics_bkno = cur.fetchall()
    bkno = [desc[0] for desc in cur.description]

    cur.execute("SELECT current_database();")
    metrics_currentdb = cur.fetchall()
    
    
    cur.close()
    conn.close()
    return bkno, metrics_bkno, metrics_currentdb

while True:
    # 解構賦值（Destructuring Assignment）
    bkno, metrics_bkno, metrics_currentdb = collect_metrics()
    
    print(bkno)
    print(metrics_bkno)
    print(metrics_currentdb)
    time.sleep(10)  