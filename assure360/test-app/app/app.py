#!/usr/bin/env python3
"""
Assure360 Test App - Simple FastAPI Application
A basic serverless Python app for testing CI/CD pipeline
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import os
import json
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Assure360 Test App",
    description="A simple serverless Python app for testing CI/CD pipeline",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# App metadata
APP_INFO = {
    "name": "Assure360 Test App",
    "version": "1.0.0",
    "description": "Serverless Python app for CI/CD testing",
    "environment": os.getenv("ENVIRONMENT", "development"),
    "region": os.getenv("AWS_REGION", "unknown")
}

@app.get("/")
async def root():
    """Root endpoint - basic info"""
    return {
        "message": "Welcome to Assure360 Test App!",
        "app": APP_INFO,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "app": APP_INFO
    }

@app.get("/hello")
async def hello(name: str = "World"):
    """Hello endpoint with optional name parameter"""
    return {
        "message": f"Hello {name} from Assure360!",
        "app": APP_INFO,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.get("/time")
async def get_time():
    """Get current time in various formats"""
    now = datetime.utcnow()
    return {
        "utc": now.isoformat() + "Z",
        "unix": int(now.timestamp()),
        "formatted": now.strftime("%Y-%m-%d %H:%M:%S UTC"),
        "app": APP_INFO
    }

@app.get("/status")
async def get_status():
    """Detailed status information"""
    return {
        "status": "operational",
        "uptime": "unknown",  # Would need process monitoring for real uptime
        "version": APP_INFO["version"],
        "environment": APP_INFO["environment"],
        "region": APP_INFO["region"],
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.get("/info")
async def get_info():
    """Detailed app information"""
    return {
        "app": APP_INFO,
        "python_version": os.sys.version,
        "environment_variables": {
            key: value for key, value in os.environ.items() 
            if key.startswith(('AWS_', 'LAMBDA_', 'ENVIRONMENT'))
        },
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.get("/test")
async def test_endpoint():
    """Test endpoint for CI/CD validation"""
    return {
        "message": "Test endpoint working!",
        "ci_cd_status": "success",
        "deployment": "verified",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

# Error handlers
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {
        "error": "Not Found",
        "message": f"The requested endpoint {request.url.path} was not found",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.exception_handler(500)
async def internal_error_handler(request, exc):
    logger.error(f"Internal server error: {exc}")
    return {
        "error": "Internal Server Error",
        "message": "An unexpected error occurred",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
