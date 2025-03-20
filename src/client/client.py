"""
Client for interacting with the spaCy NLP API server.
"""
import json
import requests
from typing import Dict, Any, Optional
import os


class NLPClient:
    """
    Client for the spaCy NLP API.
    
    Provides methods to interact with the server component.
    """
    
    def __init__(self, base_url: Optional[str] = None):
        """
        Initialize the client with the server's base URL.
        
        Args:
            base_url: Base URL of the NLP API server
                     (defaults to SPACY_API_URL environment variable or localhost:8000)
        """
        self.base_url = base_url or os.environ.get("SPACY_API_URL", "http://localhost:8000")
        
    def check_health(self) -> Dict[str, Any]:
        """
        Check if the server is running and return available models.
        
        Returns:
            Server health status
        
        Raises:
            ConnectionError: If the server cannot be reached
        """
        try:
            response = requests.get(f"{self.base_url}/health")
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            raise ConnectionError(f"Failed to connect to NLP server: {e}")
    
    def analyze_text(self, text: str, model: str = "en_core_web_sm") -> Dict[str, Any]:
        """
        Send text to the server for analysis.
        
        Args:
            text: Text to analyze
            model: spaCy model to use
            
        Returns:
            Analysis results from the server
            
        Raises:
            ConnectionError: If the server cannot be reached
            ValueError: If the server returns an error
        """
        try:
            response = requests.post(
                f"{self.base_url}/analyze",
                json={"text": text, "model": model}
            )
            
            if response.status_code == 400:
                raise ValueError(response.json().get("detail", "Unknown error"))
                
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            raise ConnectionError(f"Failed to connect to NLP server: {e}")
    
    def print_analysis(self, text: str, model: str = "en_core_web_sm"):
        """
        Analyze text and print the results in a readable format.
        
        Args:
            text: Text to analyze
            model: spaCy model to use
        """
        try:
            result = self.analyze_text(text, model)
            
            print(f"\n=== Analysis of text: '{text[:50]}...' ===\n")
            
            # Print entities
            if result["entities"]:
                print("ENTITIES:")
                for entity in result["entities"]:
                    print(f"  {entity['text']} - {entity['label']} ({entity['description']})")
            
            # Print sentences
            print("\nSENTENCES:")
            for i, sent in enumerate(result["sentences"], 1):
                print(f"  {i}. {sent}")
            
            # Print POS tags (sample)
            print("\nPART-OF-SPEECH TAGS (sample):")
            for tag in result["pos_tags"][:10]:  # Show first 10
                print(f"  {tag['text']} - {tag['pos']} ({tag['description']})")
            
            if len(result["pos_tags"]) > 10:
                print("  ...")
            
            print("\nAnalysis complete.")
            
        except (ConnectionError, ValueError) as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    # Example usage
    client = NLPClient()
    client.print_analysis(
        "Apple is looking at buying U.K. startup for $1 billion. "
        "Steve Jobs founded Apple in 1976."
    )
