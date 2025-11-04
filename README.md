# TeamSpeak 3 Server Helm Chart

Production-ready TeamSpeak 3 Server for Kubernetes with LoadBalancer and DNS support.

## Features

- ✅ UDP voice port (9987) + TCP admin ports (10011, 30033)
- ✅ Automatic DNS configuration with LoadBalancer
- ✅ Persistent data storage
- ✅ Health checks for reliability
- ✅ Configurable resource limits
- ✅ Advanced TeamSpeak environment variable support
- ✅ RBAC support with ServiceAccount
- ✅ Ingress support for TCP routing
- ✅ Security-hardened with non-root user

## Quick Start

**IMPORTANT:** You must accept the TeamSpeak license before installation!

```bash
helm repo add dev0psapp https://helm.dev0ps.app
helm repo update

helm install teamspeak dev0psapp/teamspeak \
  --namespace teamspeak \
  --create-namespace \
  --set teamspeak.license=accept
```

> **Note:** By setting `teamspeak.license=accept`, you agree to the [TeamSpeak 3 Server License Agreement](https://www.teamspeak.com/en/privacy-and-terms/).

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
  # REQUIRED: Accept the license to proceed
  license: accept

  serverName: "My TeamSpeak Server"
  serverPassword: "YourSecurePassword123!"  # RECOMMENDED: Set a password
  serverQueryPassword: "AdminPassword456!"  # Optional: Set ServerQuery password

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

### Advanced Environment Variables
```yaml
teamspeak:
  license: accept
  serverName: "Production Server"
  serverPassword: "SecurePass123!"
  serverQueryPassword: "AdminPass456!"
  queryWhitelist: "192.168.1.0/24,10.0.0.0/8"

  # Additional TeamSpeak-specific environment variables
  extraEnv:
    - name: TS3SERVER_QUERY_PROTOCOLS
      value: "raw,ssh"
    - name: TS3SERVER_DB_SQLCREATEPATH
      value: "create_sqlite"
```

### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: "nginx"
  host: "ts.example.com"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: true
    secretName: "teamspeak-tls"
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

## Resource Sizing Guide

Choose resource allocation based on expected concurrent users:

| User Count | CPU Request | CPU Limit | Memory Request | Memory Limit | Storage |
|------------|-------------|-----------|----------------|--------------|---------|
| 1-10 (Small) | 100m | 500m | 128Mi | 256Mi | 5Gi |
| 10-50 (Medium) | 250m | 1000m | 256Mi | 512Mi | 10Gi |
| 50-100 (Large) | 500m | 2000m | 512Mi | 1Gi | 20Gi |
| 100-200 (XLarge) | 1000m | 4000m | 1Gi | 2Gi | 50Gi |

**Notes:**
- TeamSpeak server runs as a single instance (no horizontal scaling)
- Voice quality and channel count affect CPU usage
- File transfers affect storage requirements
- Monitor actual usage and adjust accordingly

## Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas (fixed at 1) | `1` |
| `image.repository` | TeamSpeak image | `docker.io/teamspeak/ts3server` |
| `image.tag` | Image tag | `latest` |
| **TeamSpeak Configuration** | | |
| `teamspeak.license` | Accept license (REQUIRED) | `""` |
| `teamspeak.serverName` | Server display name | `My TeamSpeak Server` |
| `teamspeak.serverPassword` | Server password | `""` |
| `teamspeak.serverQueryPassword` | ServerQuery password | `""` |
| `teamspeak.queryWhitelist` | Query IP whitelist | `""` |
| `teamspeak.queryBlacklist` | Query IP blacklist | `""` |
| `teamspeak.extraEnv` | Additional environment variables | `[]` |
| **Service Configuration** | | |
| `service.type` | Service type (LoadBalancer/NodePort) | `LoadBalancer` |
| `service.hostname` | DNS hostname | `""` |
| `service.voice.port` | Voice port (UDP) | `9987` |
| `service.serverquery.port` | ServerQuery port (TCP) | `10011` |
| `service.filetransfer.port` | FileTransfer port (TCP) | `30033` |
| **Ingress Configuration** | | |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.host` | Ingress hostname | `""` |
| **Persistence** | | |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | PVC size | `5Gi` |
| `persistence.storageClass` | Storage class | `""` |
| **Resources** | | |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| **Security** | | |
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name | `""` |
| `podSecurityContext.fsGroup` | Pod fsGroup | `9987` |
| `securityContext.runAsUser` | Container user ID | `9987` |
| `securityContext.runAsNonRoot` | Run as non-root | `true` |

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

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -n teamspeak -- \
  telnet teamspeak 10011
```

### Common Issues

#### 1. Image Pull Errors
**Symptom:** `ErrImagePull` or `ImagePullBackOff` in pod status

**Solution:**
```bash
# Check events
kubectl describe pod -n teamspeak <pod-name>

# Verify image exists
kubectl run test --image=docker.io/teamspeak/ts3server:latest --dry-run=client -o yaml

# Add image pull secret if using private registry
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password> \
  -n teamspeak
```

Then update values:
```yaml
imagePullSecrets:
  - name: regcred
```

#### 2. License Not Accepted
**Symptom:** Pod crashes with license error in logs

**Solution:**
```bash
# Set license acceptance
helm upgrade teamspeak dev0psapp/teamspeak \
  -n teamspeak \
  --set teamspeak.license=accept
```

#### 3. PVC Stuck in Pending
**Symptom:** PersistentVolumeClaim remains in `Pending` state

**Solution:**
```bash
# Check PVC status
kubectl get pvc -n teamspeak
kubectl describe pvc -n teamspeak teamspeak

# Check available storage classes
kubectl get storageclass

# Specify storage class explicitly
helm upgrade teamspeak dev0psapp/teamspeak \
  -n teamspeak \
  --set persistence.storageClass=standard
```

#### 4. LoadBalancer IP Pending
**Symptom:** Service `EXTERNAL-IP` shows `<pending>`

**Solution:**
```bash
# Check if your cluster supports LoadBalancers
kubectl get svc -A | grep LoadBalancer

# For clusters without LoadBalancer support, use NodePort:
helm upgrade teamspeak dev0psapp/teamspeak \
  -n teamspeak \
  --set service.type=NodePort \
  --set service.voice.nodePort=30987 \
  --set service.serverquery.nodePort=30011 \
  --set service.filetransfer.nodePort=30033
```

#### 5. Pod Fails to Start (Permission Issues)
**Symptom:** Pod crashes with permission denied errors

**Solution:**
```bash
# Check pod security context
kubectl get pod -n teamspeak <pod-name> -o yaml | grep -A 10 securityContext

# Verify storage supports fsGroup
# Some storage classes don't support fsGroup, try:
helm upgrade teamspeak dev0psapp/teamspeak \
  -n teamspeak \
  --set podSecurityContext.fsGroup=null
```

#### 6. Cannot Connect to Voice Server
**Symptom:** TeamSpeak client cannot connect to voice port

**Checklist:**
```bash
# 1. Verify service is running
kubectl get svc -n teamspeak

# 2. Check if UDP port is exposed
kubectl describe svc -n teamspeak teamspeak | grep -A 5 "Port:"

# 3. Test from inside cluster
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n teamspeak -- \
  nc -zvu teamspeak 9987

# 4. Check firewall rules (cloud provider specific)
# For GKE: Ensure firewall allows UDP 9987
# For AWS: Check security groups
# For Azure: Check NSG rules
```

#### 7. Admin Token Lost
**Symptom:** Cannot find server admin token

**Solution:**
```bash
# Check ConfigMap for token retrieval script
kubectl get cm -n teamspeak

# View logs from server start
kubectl logs -n teamspeak deployment/teamspeak --tail=100 | grep -A 5 "token="

# If not found, delete the PVC and redeploy (WARNING: Deletes all data!)
kubectl delete pvc -n teamspeak teamspeak
kubectl delete pod -n teamspeak <pod-name>
```

#### 8. Health Check Failures
**Symptom:** Pod restarts frequently, readiness probe failures

**Solution:**
```bash
# Check health probe status
kubectl describe pod -n teamspeak <pod-name> | grep -A 10 "Liveness\|Readiness"

# Increase initial delay if server starts slowly
helm upgrade teamspeak dev0psapp/teamspeak \
  -n teamspeak \
  --set livenessProbe.initialDelaySeconds=60 \
  --set readinessProbe.initialDelaySeconds=30
```

### Debug Mode

Enable verbose logging:
```yaml
teamspeak:
  extraEnv:
    - name: TS3SERVER_LOG_LEVEL
      value: "debug"
```

Then check logs:
```bash
kubectl logs -n teamspeak deployment/teamspeak -f
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
