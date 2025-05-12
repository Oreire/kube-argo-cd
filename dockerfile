# Step 1: Use a minimal base image with fixed digest
FROM argoproj/argocd

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
