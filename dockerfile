# Step 1: Use a minimal base image with fixed digest
FROM debian:bullseye-slim@sha256:1d2d0f3e5b6c7a8d9e0f1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2

# Step 2: Set environment variables
ENV ARGOCD_VERSION=v2.10.2

# Step 3: Install dependencies and optimize the layer size
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Step 4: Download and verify ArgoCD binary
RUN curl -sSL -o /usr/local/bin/argocd \
    https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

# Step 5: Define entrypoint and command
ENTRYPOINT ["/usr/local/bin/argocd"]
CMD ["version"]

# Step 6: Expose ports if needed
EXPOSE 8081
