# 📊 Kubernetes Monitoring Stack

> Production-grade observability stack on Kubernetes — Prometheus, Grafana, Loki, AlertManager with email notifications.

![Kubernetes](https://img.shields.io/badge/Kubernetes-1.35-blue?logo=kubernetes)
![Prometheus](https://img.shields.io/badge/Prometheus-2.x-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-10.x-yellow?logo=grafana)
![Helm](https://img.shields.io/badge/Helm-3.x-blue?logo=helm)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)


## 🏗️ Architecture
```
┌──────────────────────────────────────────┐
│           Kubernetes Cluster             │
│                                          │
│  12 Microservices                        │
│       ↓ metrics          ↓ logs          │
│  Prometheus          Loki + Promtail     │
│       ↓                   ↓             │
│  Grafana Dashboards   Log Explorer       │
│       ↓                                  │
│  AlertManager  ──────────→  📧 Gmail    │
└──────────────────────────────────────────┘
```

---

## 🛠️ Stack

| Tool | Role | Version |
|------|------|---------|
| Kubernetes | Container orchestration | 1.35+ |
| Helm | Package manager | 3.x |
| Prometheus | Metrics collection | 2.x |
| Grafana | Visualization | 10.x |
| Loki | Log aggregation | 2.9+ |
| Promtail | Log collector agent | 2.9+ |
| AlertManager | Alert routing | 0.31+ |

---

## 📋 Prerequisites
```bash
minikube version  # >= 1.32
kubectl version   # >= 1.29
helm version      # >= 3.14
docker version    # >= 24.x
```

---

## 🚀 Quick Start
```bash
# 1. Clone the repo
git clone https://github.com/bechirhadidan/k8s-monitoring-stack.git
cd k8s-monitoring-stack

# 2. Start Minikube
minikube start --cpus=4 --memory=6144 --driver=docker
minikube addons enable metrics-server ingress

# 3. Create namespaces
kubectl create namespace monitoring
kubectl create namespace app

# 4. Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 5. Install monitoring stack
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --values monitoring/prometheus/values.yaml

helm install loki grafana/loki-stack \
  --namespace monitoring --values monitoring/loki/values.yaml

# 6. Apply configs
kubectl apply -f monitoring/prometheus/alert-rules.yaml
kubectl apply -f monitoring/alertmanager/alertmanager-config.yaml
kubectl apply -f app/
```

---

## 🖥️ Access
```bash
# Grafana → http://localhost:3000 (admin/admin123)
kubectl port-forward svc/prometheus-stack-grafana 3000:80 -n monitoring

# Prometheus → http://localhost:9090
kubectl port-forward svc/prometheus-stack-kube-prom-prometheus 9090:9090 -n monitoring

# AlertManager → http://localhost:9093
kubectl port-forward svc/prometheus-stack-kube-prom-alertmanager 9093:9093 -n monitoring
```

---

## 🔔 Alert Rules

| Alert | Condition | Severity |
|-------|-----------|----------|
| PodCrashLooping | Restart > 3x in 15min | 🔴 Critical |
| HighCPUUsage | CPU > 80% for 5min | 🟡 Warning |
| CriticalCPUUsage | CPU > 95% for 2min | 🔴 Critical |
| HighMemoryUsage | RAM > 85% | 🟡 Warning |
| ContainerOOMKilled | OOM Kill detected | 🔴 Critical |
| NodeNotReady | Node down 2min | 🔴 Critical |
| AppDown | App unreachable 1min | 🔴 Critical |

---

## 🧪 Test an Alert
```bash
# Simulate a CrashLoop
kubectl run crash-test --image=busybox --restart=Always -- /bin/sh -c "exit 1"

# Watch the alert fire in AlertManager → http://localhost:9093
# Check your Gmail inbox for the notification 📧

# Cleanup
kubectl delete pod crash-test
```

---

## 📁 Project Structure
```
k8s-monitoring-stack/
├── app/                        # Demo application
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
├── monitoring/
│   ├── prometheus/
│   │   ├── values.yaml         # Helm config
│   │   └── alert-rules.yaml    # Custom alerts
│   ├── alertmanager/
│   │   └── alertmanager-config.yaml
│   └── loki/
│       ├── values.yaml
│       └── loki-alert-rules.yaml
├── helm/
│   └── install.sh              # One-click install
├── .gitignore
└── README.md
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

---

## 📄 License

[MIT](LICENSE)

---

> Made with ❤️ by [Bechir Hadidan](https://github.com/bechir-hadiden?tab=repositories) — 2026
