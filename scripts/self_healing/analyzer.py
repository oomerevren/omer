import os
import json
import logging

# Otonom Medya Holdingi - Self-Healing Analyzer
# Goal: Detect errors in logs and suggest fixes (Human-in-the-loop)

class SelfHealing:
    def __init__(self, log_path="/storage/logs/error.log"):
        self.log_path = log_path

    def analyze_error(self, error_message):
        """
        Uses an LLM (Mistral/GPT) to analyze the error and suggest a fix.
        For now, this is a rule-based mock for the pattern.
        """
        if "Rate limit reached" in error_message:
            return {
                "root_cause": "API Rate Limit",
                "suggestion": "Increase delay between requests or implement exponential backoff.",
                "action": "UPDATE_CONFIG",
                "requires_human": True
            }
        elif "Codec Not Supported" in error_message:
            return {
                "root_cause": "FFmpeg Video Encoding Error",
                "suggestion": "Check input file codec or change output codec to libx264.",
                "action": "UPDATE_SCRIPT",
                "requires_human": True
            }
        return {"root_cause": "Unknown", "suggestion": "Manual investigation required.", "requires_human": True}

if __name__ == "__main__":
    # Example usage: python analyzer.py "Rate limit reached on X API"
    import sys
    msg = sys.argv[1] if len(sys.argv) > 1 else "No error provided"
    healer = SelfHealing()
    analysis = healer.analyze_error(msg)
    print(json.dumps(analysis, indent=2))
