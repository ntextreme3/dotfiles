#!/bin/bash
set -euo pipefail

# Kubernetes
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
