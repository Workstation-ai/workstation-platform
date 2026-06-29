from fastapi import FastAPI
from datetime import datetime
import os
import uvicorn

app = FastAPI(title="Workstation Agent")

@app.get("/health")
async def health():
    return {"status": "healthy", "agent": os.getenv("AGENT_NAME", "unknown")}

@app.get("/status")
async def status():
    return {
        "agent": os.getenv("AGENT_NAME", "unknown"),
        "user": os.getenv("USER_ID", "unknown"),
        "persistence": os.getenv("PERSISTENCE_PATH", "/home/agent/persistence")
    }

@app.post("/execute")
async def execute(command: str, user_id: str):
    return {"status": "success", "output": f"Executed: {command}"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
