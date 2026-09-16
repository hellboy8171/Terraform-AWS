#!/usr/bin/env bash
set -euo pipefail

tfsec . --soft-fail || true
