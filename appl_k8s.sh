#!/bin/bash

# 使用 git bash 執行 (win 上不能用 shell script, 而 WSL 上沒安裝 minikube)
kubectl apply -f /d/my_minikube/my_postgres/master.yaml 
kubectl wait --for=condition=ready pod -l app=postgres,role=service --timeout=60s
echo "MASTER POD IS READY"

kubectl apply -f /d/my_minikube/my_postgres/rep1.yaml 
kubectl wair --for=condition=ready pod -l app=postgres,role=replica1 --timeout=60s
echo "REP1 POD IS READY"

kubectl apply -f /d/my_minikube/my_postgres/rep2.yaml 
kubectl wait --for=condition=ready pod -l app=psotgres,role=replica2 --timeout=60s
echo "REP2 POD IS READY"

kubectl apply -f /d/my_minikube/my_postgres/pgpool.yaml 
kubectl wait --for=condition=ready pod -l app=pgpool --timeout=60s
echo "PGPOOL POD IS READY"