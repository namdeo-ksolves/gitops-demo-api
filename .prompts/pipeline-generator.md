# CI/CD Pipeline Generator — AI Prompt

## Usage
Paste this prompt to generate a GitHub Actions pipeline for any containerised app.

---

## Prompt

```
Generate a GitHub Actions CI/CD pipeline for a containerised microservice with these requirements:

Project:
- Language: Node.js 20
- Registry: {{REGISTRY_HOST}} (HTTP, insecure — add daemon.json step)
- GitOps controller: Argo CD at {{ARGOCD_URL}}
- Helm chart path: ./helm/values.yaml (tag field: `tag:`)

Pipeline stages:
1. lint-and-test — run `npm ci && npm test`, cache node_modules
2. build-and-push — Docker build with SHA tag + :latest, push both tags
3. update-helm — sed replace tag in values.yaml, commit + push with GITHUB_TOKEN
4. sync-argocd — POST to /api/v1/applications/{{APP_NAME}}/sync with Bearer token

Requirements:
- Only build on push to main branch
- Stages run sequentially (needs:)
- Secrets: HARBOR_USER, HARBOR_PASSWORD, ARGOCD_TOKEN, ARGOCD_URL
- Add permissions: contents: write to allow helm values commit
- Use git remote set-url with GITHUB_TOKEN for authenticated push

Output a single .github/workflows/ci-cd.yml file with clear step names.
```

---

## Secrets to configure in GitHub repo:
| Secret | Value |
|--------|-------|
| HARBOR_USER | admin |
| HARBOR_PASSWORD | Harbor12345 |
| ARGOCD_URL | 15.206.153.218:30858 |
| ARGOCD_TOKEN | (from ArgoCD UI → Settings → Accounts) |
