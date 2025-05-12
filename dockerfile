# Use a stable Ubuntu version as base
FROM  ubuntu:22.04

# Switch to root user for package installations
USER root

# Update package sources to ensure compatibility
RUN apt-get clean && apt-get update && \
    apt-get install -y --no-install-recommends curl git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set up ArgoCD (adjust based on your needs)
COPY --from=argoproj/argocd:latest /usr/local/bin/argocd /usr/local/bin/argocd

# Switch back to non-root user for security (if required)
USER argocd

# Define entrypoint or startup command
CMD ["/usr/local/bin/argocd", "version"]

