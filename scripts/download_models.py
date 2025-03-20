#!/usr/bin/env python3
"""
Script to download required spaCy models.
"""
import subprocess
import sys
import argparse


def download_model(model_name):
    """Download a specific spaCy model."""
    print(f"Downloading {model_name}...")
    result = subprocess.run(
        [sys.executable, "-m", "spacy", "download", model_name],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        print(f"Error downloading {model_name}: {result.stderr}")
        return False
    
    print(f"Successfully downloaded {model_name}")
    return True


def main():
    """Main entry point for the download script."""
    parser = argparse.ArgumentParser(description="Download spaCy models")
    parser.add_argument(
        "--models", 
        nargs="+", 
        default=["en_core_web_sm"],
        help="Models to download (default: en_core_web_sm)"
    )
    args = parser.parse_args()
    
    success = True
    for model in args.models:
        if not download_model(model):
            success = False
    
    if not success:
        sys.exit(1)


if __name__ == "__main__":
    main()
