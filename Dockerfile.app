# Use the latest version of the base Langflow image
FROM langflowai/langflow:latest

# Create folders and set the working directory in the container
RUN mkdir /app/flows
RUN mkdir /app/langflow-config-dir
WORKDIR /app

# Copy flows, langflow-config-dir, and docker.env to the container
COPY flows /app/flows
COPY langflow-config-dir /app/langflow-config-dir
COPY docker.env /app/.env

# Optional: Copy custom components to the container
COPY components /app/components

# Optional: Use custom dependencies
COPY pyproject.toml uv.lock /app/

# Set environment variables if not set in docker.env
ENV PYTHONPATH=/app
ENV LANGFLOW_LOAD_FLOWS_PATH=/app/flows
ENV LANGFLOW_CONFIG_DIR=/app/langflow-config-dir
ENV LANGFLOW_COMPONENTS_PATH=/app/components
ENV LANGFLOW_LOG_ENV=container

# Command to run the Langflow server on port 7860
EXPOSE 7860
CMD ["langflow", "run", "--backend-only", "--env-file","/app/.env","--host", "0.0.0.0", "--port", "7860"]
