## Key decisions for peer review

This document lists the key architecture and configuration decisions in this repository that should be peer reviewed and agreed upon before production usage.

### How to use this document
- Review each decision, confirm the target standard, and capture any deltas to implement.
- Use the referenced files to locate where changes would be made.

### Decisions

1) AWS regions and AZ strategy
- Current: Defaults to `ap-southeast-2` across stacks and workflows; AZ selection varies by module.
- Decide: Primary region(s), DR/secondaries, standard AZ counts per env (e.g., 2 AZ in prod, 1–2 in dev).
- References: `assure360/iam-foundation/variables.tf`, `assure360/test-app/infrastructure/variables.tf`, `.github/workflows/deploy-test-app.yml`.

2) Terraform remote state backend
- Current: Local state present; IAM policies imply S3 backend with DynamoDB locks but not configured.
- Decide: S3 bucket name/policy, SSE-KMS key, versioning, DynamoDB table for state locks, workspace strategy, ACLs.
- References: `assure360/iam-foundation/main.tf` (policy hints), repo `terraform.tfstate*` files.

3) Account bootstrap and organization approach
- Current: Templates for account setup; discussion of Control Tower vs direct Terraform.
- Decide: Use AWS Control Tower/Landing Zone vs custom Terraform; bootstrap role names and trust policies.
- References: `assure360/github-setup/terraform-template/account/TERRAFORM_VS_CONTROL_TOWER.md`.

4) Provider auth and assume-role pattern
- Current: Providers use `region`, optional `profile`, optional `assume_role` via `var.assume_role_arn` in some stacks.
- Decide: Standardize on SSO + OIDC + assumed roles; enforce session tags and external IDs; unify provider blocks across modules.
- References: `assure360/networking/providers.tf` and root module providers.

5) Global tagging and naming standards
- Current: `common_tags` and naming prefixes (`davidson-`) exist but vary by module.
- Decide: Required tag keys, environment taxonomy, cost-center mapping, username/resource name prefixes.
- References: `assure360/iam-foundation/variables.tf`, tags in `assure360/networking/*`.

6) VPC CIDR plan and subnet layout
- Current: Example CIDRs (e.g., `10.10.0.0/16`) and public-only subnets in some places; template module supports public/private per AZ.
- Decide: Canonical CIDR ranges, per-env overlays, number of subnets per AZ, overlap checks with on‑prem/VPN.
- References: `assure360/networking/vpc.tf`, `assure360/github-setup/terraform-template/networking/variables.tf`.

7) Public vs private workload placement
- Current: Dev ECS tasks run in public subnets with `assign_public_ip = true`.
- Decide: Prod standard should be private subnets with egress via endpoints/NAT; dev/test policy.
- References: `assure360/networking/alb_ecs.tf`, `assure360/networking/vpc.tf`.

8) Ingress and TLS policy
- Current: ALB listener is HTTP :80 only in dev; HTTPS and ACM commented/omitted.
- Decide: Enforce HTTPS, 80→443 redirect, ACM certificate procurement/validation (DNS vs email), certificate rotation.
- References: `assure360/networking/alb_ecs.tf`, `assure360/networking/README.md`.

9) VPC endpoints strategy
- Current: Endpoints defined/documented in networking; prod guidance present; cost noted.
- Decide: Required endpoints per env (S3, ECR, Logs, ECS, STS, SSM), private DNS settings, endpoint SG rules.
- References: `assure360/networking/endpoints.tf`, `assure360/networking/README.md`.

10) NAT gateway policy and cost posture
- Current: Template exposes `enable_nat_gateway`; prod readme suggests NAT in private subnets.
- Decide: NAT per AZ vs single-AZ, dev/test cost controls (NAT instance or disabled), data processing monitoring.
- References: `assure360/github-setup/terraform-template/networking/variables.tf`, `assure360/networking/README.md`.

11) ECS service sizing and scaling
- Current: Task definition uses CPU 512 / Mem 1024; desired count is variable; no autoscaling policies.
- Decide: Per-env cpu/memory, desired/min/max tasks, autoscaling on CPU/ALB target, deployment configuration.
- References: `assure360/networking/alb_ecs.tf`.

12) ECS networking and health checks
- Current: `target_type = "ip"`, container `8080`, health path `/`, public ALB.
- Decide: Standard ports, health endpoints, deregistration delay, stickiness, slow start, ALB/NLB choice.
- References: `assure360/networking/alb_ecs.tf`.

13) Logging, metrics, and retention
- Current: CloudWatch Logs retention = 7 days for dev; no alarms defined in code.
- Decide: Retention per env (e.g., 30/90/365), metric filters, alarms (5xx, unhealthy hosts), log group naming.
- References: `assure360/networking/alb_ecs.tf` (log group), observability gaps elsewhere.

14) ECR repository policies
- Current: ECR usage is documented; repository resource present; lifecycle/immutability not explicit.
- Decide: Image scanning on push, immutable tags, lifecycle rules, encryption (KMS), repo naming conventions.
- References: `assure360/networking/ecr.tf`, `assure360/test-app/ARCHITECTURE.md`.

15) IAM baseline access model
- Current: Groups: admins (AdministratorAccess), developers (minimal + MFA + optional elevated PowerUser), support (ReadOnly + MFA).
- Decide: Exact rights in DevMinimal, session durations, permissions boundaries, SCPs (if org), break-glass processes.
- References: `assure360/iam-foundation/main.tf`, `assure360/iam-foundation/README.md`.

16) IAM users and access keys policy
- Current: Templates can create IAM users and programmatic keys, including admin.
- Decide: Human access via SSO vs local IAM users, key creation/rotation/storage policy, console login profiles, MFA enforcement.
- References: `assure360/github-setup/terraform-template/users/main.tf`, `assure360/iam-users/*`.

17) GitHub OIDC enablement and scope
- Current: OIDC provider and CI/CD roles/policies present but optional via toggle.
- Decide: Org/repo allowlist, claims/conditions, per-env roles, least-privilege permissions for plan/apply and ECS updates.
- References: `assure360/iam-foundation/variables.tf`, `assure360/iam-foundation/main.tf` (GitHub Actions policies).

18) CI/CD environment mapping and approvals
- Current: Branch-to-env rules (dev/prod), automatic apply on push, prod approvals are not enforced in code.
- Decide: Manual approvals for prod, plan visibility and drift checks, artifact retention, rollback strategy.
- References: `.github/workflows/*`, `CI-CD-PIPELINE.md`.

19) Security groups and egress posture
- Current: ALB ingress 80/443 from internet; ECS tasks SG restricted to ALB; default egress often open.
- Decide: Lock down ingress sources, restrict egress by CIDR/ports, baseline SGs per env, WAF/Shield considerations.
- References: `assure360/networking/security.tf`.

20) Parameter Store and KMS usage
- Current: Parameter Store scaffolding exists; KMS usage not standardized across modules.
- Decide: Parameter hierarchy (e.g., `/env/app/...`), which values are encrypted, KMS key policy/rotation, access controls.
- References: `assure360/github-setup/terraform-template/parameter-store/*`.

### Next steps
- Confirm decisions and capture target standards in module variables and docs.
- Implement remote state with S3 + DynamoDB and update all roots.
- Enforce provider and tagging standards across modules.
- Tighten prod posture: private subnets, HTTPS-only, endpoints, logging/alarms, and least-privilege IAM.


