#!/usr/bin/env bash
set -euo pipefail

env="${1:-dev}"
terraform -chdir="environments/${env}" init -backend-config=backend.hcl
terraform -chdir="environments/${env}" plan -detailed-exitcode || true
