FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir mcp-proxy

# Copy application code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e .

EXPOSE 8000

# Use mcp-proxy to expose the stdio-based MCP server over SSE
# The ticktick MCP runs via: python -m ticktick_mcp.cli run
CMD ["mcp-proxy", "--host", "0.0.0.0", "--port", "8000", "--pass-environment", "--allow-origin", "*", "python", "-m", "ticktick_mcp.cli", "run"]
