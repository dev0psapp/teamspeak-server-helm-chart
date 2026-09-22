# teamspeak

![Version: 1.2.0](https://img.shields.io/badge/Version-1.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.2.0](https://img.shields.io/badge/AppVersion-1.2.0-informational?style=flat-square)

Helm chart for a TeamSpeak 3 server on Kubernetes. It runs a single server instance, keeps the server data on a persistent volume, and exposes the voice, ServerQuery and file transfer ports through a Service. Set `service.hostname` when the server should be reachable on a public DNS name.

The published server image is `ghcr.io/dev0psapp/teamspeak-server-helm-chart:1.2.0`.

## Prerequisites

- Kubernetes 1.25 or newer
- Helm 3
- A LoadBalancer implementation, or another Service type if clients reach the server another way
- external-dns, when `service.hostname` should create the DNS record automatically

Open these ports to the clients:

| Port | Protocol | Purpose |
| --- | --- | --- |
| 9987 | UDP | Voice |
| 10011 | TCP | ServerQuery |
| 30033 | TCP | File transfer |

## Install

```bash
helm repo add teamspeak https://dev0psapp.github.io/teamspeak-server-helm-chart/
helm repo update

helm install my-teamspeak teamspeak/teamspeak \
  --namespace teamspeak \
  --create-namespace
```

## Example with a public address

This example publishes the server as `teamspeak.domainnameformyts.com`. The chart adds that name as an external-dns hostname on the Service. Point the name at the LoadBalancer address if external-dns is not installed.

Save this as `values-teamspeak.yaml`:

```yaml
image:
  repository: ghcr.io/dev0psapp/teamspeak-server-helm-chart
  tag: "1.2.0"

teamspeak:
  license: accept
  serverName: "My TeamSpeak Server"

service:
  type: LoadBalancer
  hostname: teamspeak.domainnameformyts.com

persistence:
  enabled: true
  size: 5Gi
```

Install it with those values:

```bash
helm install my-teamspeak teamspeak/teamspeak \
  --namespace teamspeak \
  --create-namespace \
  -f values-teamspeak.yaml
```

Wait until the LoadBalancer has an address:

```bash
kubectl get svc -n teamspeak my-teamspeak -w
```

Connect with the TeamSpeak client to:

```text
teamspeak.domainnameformyts.com
```

The voice port is `9987/UDP`. The first start prints a server admin privilege key in the pod log:

```bash
kubectl logs -n teamspeak deployment/my-teamspeak | grep token=
```

Use that key once in the client to claim server admin. Upgrade with the same values file:

```bash
helm upgrade my-teamspeak teamspeak/teamspeak \
  --namespace teamspeak \
  -f values-teamspeak.yaml
```

## Configuration

| Key | Default | Description |
| --- | --- | --- |
| `image.repository` | `ghcr.io/dev0psapp/teamspeak-server-helm-chart` | Server image |
| `image.tag` | `1.2.0` | Image tag, matches the chart app version |
| `teamspeak.license` | `accept` | TeamSpeak license acceptance passed to the container |
| `teamspeak.serverName` | `My TeamSpeak Server` | ServerQuery name |
| `teamspeak.extraEnv` | `[]` | Extra environment variables for the container |
| `service.type` | `LoadBalancer` | Service type |
| `service.hostname` | `""` | Public DNS name, also set as an external-dns hostname |
| `service.loadBalancerIP` | `""` | Fixed LoadBalancer address |
| `service.voice.port` | `9987` | Voice port |
| `service.serverquery.port` | `10011` | ServerQuery port |
| `service.filetransfer.port` | `30033` | File transfer port |
| `persistence.enabled` | `true` | Store server data on a persistent volume |
| `persistence.size` | `5Gi` | Volume size |
| `persistence.storageClass` | `""` | Storage class, empty uses the cluster default |
| `resources.requests.cpu` | `100m` | CPU request |
| `resources.requests.memory` | `128Mi` | Memory request |
| `resources.limits.cpu` | `1000m` | CPU limit |
| `resources.limits.memory` | `512Mi` | Memory limit |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| dev0ps | <admin@dev0ps.app> | https://dev0ps.app |

## Source Code

* <https://github.com/dev0psapp/teamspeak-server-helm-chart>
