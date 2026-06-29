from fastapi import FastAPI
from datetime import datetime
import os
import uvicorn

app = FastAPI(title="Workstation MCP Server")

@app.get("/health")
async def health():
    return {"status": "healthy", "version": "1.0.0", "timestamp": datetime.now().isoformat()}

@app.get("/")
async def root():
    return {"message": "Workstation MCP Server", "status": "running"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
