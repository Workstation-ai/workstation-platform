FROM python:3.11-slim
WORKDIR /home/agent
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
RUN mkdir -p /home/agent/persistence && useradd --create-home agent && chown -R agent:agent /home/agent
USER agent
EXPOSE 8080
CMD ["uvicorn", "src.agent:app", "--host", "0.0.0.0", "--port", "8080"]
