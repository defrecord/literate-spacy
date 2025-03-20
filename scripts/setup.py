#!/usr/bin/env python3
"""
Setup script for the spaCy NLP tool.
"""
from setuptools import setup, find_packages

setup(
    name="spacy-nlp-tool",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "spacy>=3.5.0",
        "fastapi>=0.95.0",
        "uvicorn>=0.21.0",
        "requests>=2.28.0",
        "pydantic>=1.10.0",
    ],
    entry_points={
        "console_scripts": [
            "nlp-server=src.server.server:start_server",
        ],
    },
    python_requires=">=3.8",
    author="Claude",
    author_email="example@example.com",
    description="A simple NLP tool using spaCy",
)
