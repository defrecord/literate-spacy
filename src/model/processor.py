"""
Core NLP text processing functionality using spaCy.
"""
import spacy
from typing import Dict, List, Any, Optional


class NLPProcessor:
    """Primary NLP processor using spaCy models."""
    
    def __init__(self, model_name: str = "en_core_web_sm"):
        """
        Initialize the NLP processor with the specified spaCy model.
        
        Args:
            model_name: Name of the spaCy model to load
        """
        self.model_name = model_name
        try:
            self.nlp = spacy.load(model_name)
        except OSError:
            raise ValueError(f"Model {model_name} not found. Run download_models.py first.")
            
    def analyze_text(self, text: str, components: Optional[List[str]] = None) -> Dict[str, Any]:
        """
        Perform basic NLP analysis on the provided text.
        
        Args:
            text: Input text to analyze
            components: List of analysis components to include
                        (options: entities, tokens, sentences, pos_tags, dependencies)
                        If None, include all components.
            
        Returns:
            Dictionary with analysis results for selected components
        """
        # Input validation
        if len(text) > 100000:
            raise ValueError("Text too long. Maximum length is 100,000 characters.")
            
        # Process the text
        doc = self.nlp(text)
        
        # Prepare results dictionary
        result = {}
        
        # Default to all components if not specified
        if components is None:
            components = ["entities", "tokens", "sentences", "pos_tags", "dependencies"]
            
        # Add requested components to results
        if "entities" in components:
            result["entities"] = self._get_entities(doc)
            
        if "tokens" in components:
            result["tokens"] = self._get_tokens(doc)
            
        if "sentences" in components:
            result["sentences"] = self._get_sentences(doc)
            
        if "pos_tags" in components:
            result["pos_tags"] = self._get_pos_tags(doc)
            
        if "dependencies" in components:
            result["dependencies"] = self._get_dependencies(doc)
            
        return result
    
    def _get_entities(self, doc) -> List[Dict[str, Any]]:
        """Extract named entities from spaCy doc."""
        return [
            {"text": ent.text, "start": ent.start_char, "end": ent.end_char, 
             "label": ent.label_, "description": spacy.explain(ent.label_)}
            for ent in doc.ents
        ]
    
    def _get_tokens(self, doc) -> List[Dict[str, str]]:
        """Extract basic token information from spaCy doc.
        Includes text and lemma for each token."""
        return [
            {"text": token.text, "lemma": token.lemma_, "is_stop": token.is_stop}
            for token in doc
        ]
    
    def _get_sentences(self, doc) -> List[Dict[str, Any]]:
        """Extract sentences from spaCy doc with metadata."""
        return [
            {
                "text": sent.text,
                "start": sent.start_char,
                "end": sent.end_char,
                "tokens_count": len(sent)
            } 
            for sent in doc.sents
        ]
    
    def _get_pos_tags(self, doc) -> List[Dict[str, str]]:
        """Extract part-of-speech tags from spaCy doc."""
        return [
            {"text": token.text, "pos": token.pos_, "description": spacy.explain(token.pos_)}
            for token in doc
        ]
    
    def _get_dependencies(self, doc) -> List[Dict[str, Any]]:
        """Extract dependency parsing information from spaCy doc."""
        return [
            {"text": token.text, "dep": token.dep_, 
             "head": token.head.text, "description": spacy.explain(token.dep_)}
            for token in doc
        ]
