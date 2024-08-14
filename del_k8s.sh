#!/bin/bash

# 使用 git bash 執行 (win 上不能用 shell script, 而 WSL 上沒安裝 minikube)
kubectl delete -f /d/my_minikube/my_postgres/pgpool.yaml 
kubectl delete -f /d/my_minikube/my_postgres/rep1.yaml 
kubectl delete -f /d/my_minikube/my_postgres/rep2.yaml 
kubectl delete -f /d/my_minikube/my_postgres/master.yaml 

minikube ssh 'sudo rm -rf /data/*;
         exit'