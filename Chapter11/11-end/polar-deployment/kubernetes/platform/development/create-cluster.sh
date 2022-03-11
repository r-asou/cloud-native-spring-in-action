#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile polar

echo "\n🔌 Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile polar

echo "\n📦 Deploying platform services..."

kubectl apply -f services

sleep 5

echo "\n⌛ Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=polar-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-postgres \
  --timeout=90s

echo "\n⌛ Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=90s

echo "\n⌛ Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-rabbitmq \
  --timeout=90s

echo "⌛ Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=polar-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-keycloak \
  --timeout=300s

echo "\n⛵ Happy Sailing!\n"
