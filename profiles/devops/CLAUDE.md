# Project Instructions

## Stack
Docker, Kubernetes, Terraform, GitHub Actions, AWS/GCP

## Commands
- `docker compose up -d` — start local environment
- `docker compose logs -f` — follow logs
- `terraform plan` — preview infrastructure changes
- `terraform validate` — validate config
- `kubectl get pods` — check pod status
- `helm lint ./charts/*` — lint Helm charts

## Architecture
- `infra/` — Terraform modules
  - `modules/` — reusable Terraform modules
  - `environments/` — per-environment configs (dev, staging, prod)
- `k8s/` — Kubernetes manifests
- `docker/` — Dockerfiles and compose configs
- `.github/workflows/` — CI/CD pipelines
- `scripts/` — operational scripts

## Critical Constraints
- NEVER run `terraform apply` or `terraform destroy` without explicit approval
- NEVER run `kubectl delete` on production resources
- All infrastructure changes must go through Terraform (no manual console changes)
- Docker images must use specific version tags, never `:latest`
- All secrets must be managed through a secrets manager, never in plain text
- Every resource must have tags/labels for cost tracking
- Terraform state must use remote backend with locking
