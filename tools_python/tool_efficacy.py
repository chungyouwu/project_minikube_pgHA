
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
    

    cur.execute("SELECT current_database();")
    metrics_currentdb = cur.fetchall()

    conn.close()
    return metrics_bkno, metrics_currentdb

while True:
    metrics_bkno, metrics_currentdb = collect_metrics()
    # 在此處可以選擇將指標保存到文件或數據庫
    print(metrics_bkno)
    print(metrics_currentdb)
    time.sleep(10)  # 每五分鐘收集一次指標