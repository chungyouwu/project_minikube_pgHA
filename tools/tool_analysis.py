import pandas as pd
import matplotlib.pyplot as plt

# 假設我們有已收集的性能數據
data = {
    'timestamp': ['2024-08-01 12:00', '2024-08-01 12:05', '2024-08-01 12:10'],
    'numbackends': [20, 25, 22],
    'xact_commit': [1000, 1100, 1150],
    'xact_rollback': [10, 12, 11],
}

df = pd.DataFrame(data)

# 將時間戳轉為日期時間格式
df['timestamp'] = pd.to_datetime(df['timestamp'])

# 繪製查詢提交數量的趨勢圖
plt.plot(df['timestamp'], df['xact_commit'], label='Transaction Commits')
plt.xlabel('Time')
plt.ylabel('Commits')
plt.title('Transaction Commit Trend')
plt.legend()
plt.grid(True)
plt.show()