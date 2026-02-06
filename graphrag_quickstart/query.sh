#!/bin/bash
# GraphRAG query wrapper that suppresses cleanup errors

source "$(dirname "$0")/venv/bin/activate"

# API key must be set via environment variable or .env file
if [ -z "$GRAPHRAG_API_KEY" ]; then
    # Try to load from .env if it exists
    if [ -f "$(dirname "$0")/.env" ]; then
        export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
    fi
fi

if [ -z "$GRAPHRAG_API_KEY" ]; then
    echo "Error: GRAPHRAG_API_KEY is not set."
    echo "Please set it via: export GRAPHRAG_API_KEY='your-key'"
    echo "Or create a .env file with: GRAPHRAG_API_KEY=your-key"
    exit 1
fi

# Run query and filter out the SSL/asyncio cleanup errors
graphrag query "$@" 2>&1 | grep -v -E "(Fatal error on SSL|Event loop is closed|RuntimeError|OSError|Traceback|File \"|asyncio|protocol:|transport:|self\._|n = self|During handling)"
