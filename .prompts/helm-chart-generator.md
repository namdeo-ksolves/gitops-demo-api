# Helm Chart Generator — AI Prompt

## Usage
Paste this prompt into ChatGPT / Claude to generate a production-ready Helm chart for any microservice.

---

## Prompt

```
Generate a production-ready Helm chart for a Node.js microservice with the following requirements:

App details:
- Name: {{APP_NAME}}
- Docker image: {{REGISTRY}}/{{IMAGE_NAME}}:{{TAG}}
- Port: {{PORT}}
- Replicas: 2 (prod), 1 (dev)

Include:
1. Deployment with:
   - Rolling update strategy (maxSurge: 1, maxUnavailable: 0)
   - Liveness probe: GET /health every 10s, failureThreshold 3
   - Readiness probe: GET /health every 5s
   - Resource limits: 500m CPU / 512Mi memory
   - Resource requests: 100m CPU / 128Mi memory
   - ConfigMap-backed environment variables

2. Service:
   - ClusterIP for internal traffic
   - NodePort for demo access (port 31000)

3. HorizontalPodAutoscaler:
   - Min: 2, Max: 10
   - CPU target: 70%

4. Values.yaml with environment overrides (dev/staging/prod)

5. NOTES.txt with access instructions

Output only valid YAML files. Label all resources with: app, version, managed-by=Helm.
```

---

## Expected Output Structure
```
mychart/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-prod.yaml
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── hpa.yaml
    ├── configmap.yaml
    └── NOTES.txt
```

## Live Demo Command
```bash
# Install with dev values
helm install gitops-demo ./helm -f helm/values-dev.yaml -n demo

# Upgrade with prod values  
helm upgrade gitops-demo ./helm -f helm/values-prod.yaml -n demo

# Watch rollout
kubectl rollout status deployment/gitops-demo -n demo -w
```
