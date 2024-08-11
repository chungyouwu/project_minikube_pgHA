-- DB 健康狀況
SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit 
FROM pg_stat_database;



-- 表格 I/O 狀況: 
SELECT
  relname AS table_name,
  heap_blks_hit AS heap_hits,
  heap_blks_read AS heap_reads,
  (heap_blks_hit::float /nullif( (heap_blks_hit + heap_blks_read),0 )) AS hit_ratio
FROM pg_statio_user_tables
ORDER BY hit_ratio DESC;

-- 最花時間的 query
SELECT round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) percent, 
           round(total_exec_time::numeric, 2) AS total,                  
           calls,                                                   
           round(mean_exec_time::numeric, 2) AS mean,                    
           substring(query, 1, 200)                                  
FROM  pg_stat_statements                                               
ORDER BY total_exec_time DESC                                               
LIMIT 10;



-- 表格動作比例
SELECT relname,
       trunc(cast(n_tup_ins AS numeric) / nullif((n_tup_ins + n_tup_upd + n_tup_del),0),2) AS ins_pct,
       trunc(cast(n_tup_upd AS numeric) / nullif((n_tup_ins + n_tup_upd + n_tup_del),0),2) AS upd_pct,
       trunc(cast(n_tup_del AS numeric) / nullif((n_tup_ins + n_tup_upd + n_tup_del),0),2) AS del_pct 
FROM pg_stat_user_tables 
ORDER BY relname;


-- 查看表格使用索引取得資料比率
SELECT relname, seq_tup_read, idx_tup_fetch,
       cast(idx_tup_fetch AS numeric) / (idx_tup_fetch + seq_tup_read) AS idx_fetch_pct 
FROM pg_stat_user_tables 
WHERE (idx_tup_fetch + seq_tup_read) > 0 ORDER BY idx_fetch_pct;



-- 查看最占用緩存空間的表(顯示數量)
SELECT c.relname, count(*) AS buffers
FROM pg_class c
INNER JOIN pg_buffercache b ON b.relfilenode=c.relfilenode
INNER JOIN pg_database d ON (b.reldatabase=d.oid AND d.datname=current_database())
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 10;

