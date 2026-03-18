#!/bin/bash
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "╔══════════════════════════════════════════════════╗"
echo "║   K8s Monitoring Stack — Installation Script    ║"
echo "╚══════════════════════════════════════════════════╝"

log_info "Démarrage de Minikube..."
minikube start --cpus=4 --memory=6144 --driver=docker 2>/dev/null || log_warning "Minikube déjà démarré"
minikube addons enable metrics-server
minikube addons enable ingress

log_info "Création des namespaces..."
kubectl create namespace monitoring 2>/dev/null || log_warning "namespace 'monitoring' existe déjà"
kubectl create namespace app 2>/dev/null        || log_warning "namespace 'app' existe déjà"

log_info "Ajout des repos Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

log_info "Installation de kube-prometheus-stack (2-3 minutes)..."
helm upgrade --install prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values monitoring/prometheus/values.yaml \
  --wait --timeout 10m

log_info "Installation de Loki + Promtail..."
helm upgrade --install loki \
  grafana/loki-stack \
  --namespace monitoring \
  --values monitoring/loki/values.yaml \
  --wait --timeout 5m

log_info "Application des règles d'alertes..."
kubectl apply -f monitoring/prometheus/alert-rules.yaml

log_info "Déploiement de l'application demo..."
kubectl apply -f app/
kubectl rollout status deployment/demo-app -n app --timeout=120s

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║           Installation terminée ! 🎉            ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "  # Terminal 1 — Grafana (admin / admin123)"
echo "  kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring"
echo ""
echo "  # Terminal 2 — Prometheus"
echo "  kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring"
echo ""
echo "  # Terminal 3 — AlertManager"
echo "  kubectl port-forward svc/prometheus-stack-kube-prom-alertmanager 9093:9093 -n monitoring"
