"""
FastAPI server providing NLP endpoints using our processor.
"""
import os
from typing import Dict, Any, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

from ..model.processor import NLPProcessor


class TextRequest(BaseModel):
    """Request model for text analysis."""
    text: str
    model: Optional[str] = "en_core_web_sm"


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""
    status: str
    models_available: Dict[str, bool]


app = FastAPI(title="spaCy NLP API", 
              description="A simple API for text analysis using spaCy")

# Global processors cache
processors = {}


@app.on_event("startup")
async def startup_event():
    """Initialize default processor on startup."""
    # Load the default model
    default_model = os.environ.get("DEFAULT_SPACY_MODEL", "en_core_web_sm")
    try:
        processors[default_model] = NLPProcessor(model_name=default_model)
    except ValueError as e:
        print(f"Warning: Could not load default model: {e}")


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Check if the API is running and which models are available."""
    models = ["en_core_web_sm", "en_core_web_md", "en_core_web_lg"]
    
    return {
        "status": "ok",
        "models_available": {
            model: model in processors for model in models
        }
    }


@app.post("/analyze")
async def analyze_text(request: TextRequest) -> Dict[str, Any]:
    """
    Analyze the provided text with the specified model.
    
    Args:
        request: The text analysis request
        
    Returns:
        Dictionary with analysis results
    """
    model_name = request.model
    
    # Load the model if not already loaded
    if model_name not in processors:
        try:
            processors[model_name] = NLPProcessor(model_name=model_name)
        except ValueError:
            raise HTTPException(
                status_code=400, 
                detail=f"Model '{model_name}' not available. Run download_models.py first."
            )
    
    # Process the text
    processor = processors[model_name]
    return processor.analyze_text(request.text)


def start_server(host: str = "0.0.0.0", port: int = 8000):
    """Start the server with the given host and port."""
    uvicorn.run(app, host=host, port=port)


if __name__ == "__main__":
    start_server()
