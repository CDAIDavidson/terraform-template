"""
AWS Lambda handler for the Assure360 Test App
This file bridges FastAPI with AWS Lambda using Mangum
"""

from mangum import Mangum
from app import app

# Create the Lambda handler
handler = Mangum(app, lifespan="off")

# For local testing
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
