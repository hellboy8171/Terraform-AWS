# Terraform Best Practices & Pitfalls

A guide to writing predictable, maintainable, and safe Terraform code in production environments.

---

## 📦 Inputs
- **Typed**: Declare variable types (`string`, `number`, `list`, etc.) to prevent misuse.
- **Documented**: Add descriptions so maintainers understand purpose.
- **Validated**: Use `validation` blocks to enforce constraints (e.g., `env` must be `"dev"` or `"prod"`).
- **Defaults**: Only set safe defaults (e.g., region, small instance size). Avoid defaults for critical values like environment or secrets.

---

## 📤 Outputs
- **Expose IDs & Endpoints**: Output values such as `vpc_id`, `subnet_ids`, `eks_cluster_endpoint`.
- **Consumption by Layers**: Reference outputs in downstream modules instead of hardcoding IDs.
- **Best Practice**: Outputs act as contracts between layers (e.g., network → security → platform).

---

## 🔄 for_each vs count
- **count**: Indexes resources numerically (`0, 1, 2`). Removing one item renumbers others → destructive churn.
- **for_each**: Keys resources by stable identifiers (e.g., names). Removing one item doesn’t affect others.

**Example:**
```hcl
resource "aws_subnet" "private" {
  for_each = {
    "a" = "10.0.1.0/24"
    "b" = "10.0.2.0/24"
    "c" = "10.0.3.0/24"
  }
  cidr_block        = each.value
  availability_zone = each.key
}


Removing "b" only destroys that subnet — "a" and "c" remain untouched.

⚙️ Why This Matters
Inputs → enforce correctness at boundaries.

Outputs → provide clean contracts between modules/layers.

for_each → ensures stability and avoids destructive renumbering.

Together, these practices make Terraform code predictable, maintainable, and safe.

🔐 Secrets Management
Terraform struggles with secrets because state files record everything.

✅ Do
Create secret containers, not secret values (e.g., AWS Secrets Manager entry).

Fetch secrets dynamically (data sources, IRSA).

Mark sensitive data (sensitive = true) to hide from CLI.

Encrypt state files & storage with KMS.

Rotate credentials regularly.

🚫 Don’t
Never hardcode secrets in .tf or .tfvars.

Don’t echo secrets in outputs or CI logs.

Don’t assume sensitive = true encrypts state.

Avoid static AWS keys in pods — use IRSA.

Takeaway: Terraform manages secret containers, not secret values.
If a secret touches a plan/state → rotate immediately.

🟣 Production Pipeline
PR opened

Run fmt, validate, tflint.

Security scan.

Fail fast.

Plan on dev

Auto plan + apply in dev.

Sandbox validation.

Plan on prod

Generate read-only plan.

Post as PR comment.

Reviewers approve impact, not just code.

Human approval

Lead engineer approval.

Two approvals for destructive changes.

Apply on merge

Gated role executes terraform apply.

Auth via OIDC (no long-lived creds).

Drift check

Nightly plan on dev/prod.

Detect manual changes early.

Big Picture:  
Automation for speed, human review for safety, secure applies, continuous drift detection.

⚠️ Common Pitfalls
Silent replace  
Minor edits can trigger destroy/recreate (-/+).
→ Always read plan summaries.

Destroy in wrong directory  
Can wipe unintended resources.
→ Use prevent_destroy = true, enable deletion protection.

Console fixes during incidents  
Manual changes cause drift.
→ Write fixes back into code immediately.

Unpinned providers  
Provider updates change defaults.
→ Commit .terraform.lock.hcl.

Routine -target  
Leaves partial state, hides drift.
→ Use only for debugging.

One giant state file  
Causes slow plans, lock contention, huge blast radius.
→ Split infra into layers (network, security, platform, etc.).

Overall takeaway:  
Terraform is powerful but unforgiving.
Discipline (version pinning, state isolation, plan review) prevents outages.