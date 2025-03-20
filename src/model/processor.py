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
            
    def analyze_text(self, text: str) -> Dict[str, Any]:
        """
        Perform basic NLP analysis on the provided text.
        
        Args:
            text: Input text to analyze
            
        Returns:
            Dictionary with analysis results
        """
        doc = self.nlp(text)
        
        return {
            "entities": self._get_entities(doc),
            "tokens": self._get_tokens(doc),
            "sentences": self._get_sentences(doc),
            "pos_tags": self._get_pos_tags(doc),
            "dependencies": self._get_dependencies(doc)
        }
    
    def _get_entities(self, doc) -> List[Dict[str, Any]]:
        """Extract named entities from spaCy doc."""
        return [
            {"text": ent.text, "start": ent.start_char, "end": ent.end_char, 
             "label": ent.label_, "description": spacy.explain(ent.label_)}
            for ent in doc.ents
        ]
    
    def _get_tokens(self, doc) -> List[Dict[str, str]]:
        """Extract basic token information from spaCy doc."""
        return [
            {"text": token.text, "lemma": token.lemma_}
            for token in doc
        ]
    
    def _get_sentences(self, doc) -> List[str]:
        """Extract sentences from spaCy doc."""
        return [sent.text for sent in doc.sents]
    
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
