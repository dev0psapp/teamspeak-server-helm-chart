# TeamSpeak 3 Server Helm Chart

Production-ready TeamSpeak 3 Server for Kubernetes with LoadBalancer and DNS support.

## Features

- ✅ UDP voice port (9987) + TCP admin ports (10011, 30033)
- ✅ Automatic DNS configuration with LoadBalancer
- ✅ Persistent data storage
- ✅ Health checks for reliability
- ✅ Configurable resource limits

## Quick Start
```bash
helm repo add dev0psapp https://helm.dev0ps.app
helm repo update

helm install teamspeak dev0psapp/teamspeak \
  --namespace teamspeak \
  --create-namespace
```

## Configuration

### Basic Example
```bash
helm install teamspeak dev0psapp/teamspeak \
  --namespace teamspeak \
  --create-namespace \
  --set service.hostname="ts.example.com" \
  --set teamspeak.serverName="My TeamSpeak Server"
```

### Custom Values File

Create a `values.yaml` file:
```yaml
# TeamSpeak Server Configuration
teamspeak:
  license: accept
  serverName: "My TeamSpeak Server"
  serverPassword: ""

# Service Configuration
service:
  type: LoadBalancer
  hostname: "ts.example.com"
  
  # Optional: Fixed LoadBalancer IP
  # loadBalancerIP: "203.0.113.10"
  
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "ts.example.com"
  
  voice:
    port: 9987
    protocol: UDP
  
  serverquery:
    port: 10011
    protocol: TCP
  
  filetransfer:
    port: 30033
    protocol: TCP

# Persistent Storage
persistence:
  enabled: true
  size: 10Gi

# Resources
resources:
  limits:
    cpu: 2000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 256Mi
```

Install with values file:
```bash
helm install teamspeak dev0psapp/teamspeak \
  --namespace teamspeak \
  --create-namespace \
  --values values.yaml
```

## Examples

### NodePort Service (No LoadBalancer)
```yaml
service:
  type: NodePort
  voice:
    nodePort: 30987
  serverquery:
    nodePort: 30011
  filetransfer:
    nodePort: 30033
```

### Small Cluster Resources
```yaml
resources:
  limits:
    cpu: 1000m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Custom Storage Class
```yaml
persistence:
  enabled: true
  storageClass: "local-path"
  size: 20Gi
```

## Post-Installation

### Get Admin Token
```bash
kubectl logs -n teamspeak deployment/teamspeak | grep "token="
```

### Get Service IP
```bash
kubectl get svc -n teamspeak
```

### DNS Configuration

Point your domain to the LoadBalancer IP:
```
Type: A
Host: ts
Value: <LoadBalancer-IP>
TTL: 300
```

### Connect

- **Server:** `ts.example.com`
- **Token:** (from admin token command)

## Upgrading
```bash
helm repo update dev0psapp
helm upgrade teamspeak dev0psapp/teamspeak \
  --namespace teamspeak \
  --values values.yaml
```

## Uninstall
```bash
helm uninstall teamspeak --namespace teamspeak
```

To delete namespace and data:
```bash
kubectl delete namespace teamspeak
```

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | TeamSpeak image | `teamspeak` |
| `image.tag` | Image tag | `latest` |
| `teamspeak.license` | Accept license | `accept` |
| `teamspeak.serverName` | Server display name | `My TeamSpeak Server` |
| `service.type` | Service type (LoadBalancer/NodePort) | `LoadBalancer` |
| `service.hostname` | DNS hostname | `""` |
| `service.voice.port` | Voice port (UDP) | `9987` |
| `service.serverquery.port` | ServerQuery port (TCP) | `10011` |
| `service.filetransfer.port` | FileTransfer port (TCP) | `30033` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | PVC size | `5Gi` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `512Mi` |

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n teamspeak
kubectl describe pod -n teamspeak <pod-name>
kubectl logs -n teamspeak deployment/teamspeak -f
```

### Check Service
```bash
kubectl get svc -n teamspeak
kubectl describe svc -n teamspeak teamspeak
```

### Test Connectivity
```bash
# Test ServerQuery port
telnet ts.example.com 10011
```

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- LoadBalancer support or NodePort access
- Optional: external-dns for automatic DNS

## Repository

Charts hosted at: **https://helm.dev0ps.app**

## Support

- [TeamSpeak Documentation](https://teamspeak.com/en/downloads/#server)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
