# GraphRAG Quickstart Instructions

This directory contains a pre-built GraphRAG index for "A Christmas Carol" by Charles Dickens. The indexes are ready to use - no need to re-run the indexing process.

## Configuration

| Component | Provider | Model |
|-----------|----------|-------|
| Chat LLM | Groq | `llama-3.3-70b-versatile` |
| Embeddings | Ollama (local) | `nomic-embed-text` |
| Vector Store | LanceDB | Local file storage |
| GraphRAG Version | 2.7.0 | |

---

## Quick Setup

### Step 1: Create Virtual Environment

```bash
cd graphrag_quickstart

# Create venv with Python 3.10+
python3 -m venv venv

# Activate venv
source venv/bin/activate  # macOS/Linux
# OR
venv\Scripts\activate     # Windows
```

### Step 2: Install Dependencies

```bash
# Install from requirements.txt
pip install -r requirements.txt

# Download spaCy language model (required for NLP)
python -m spacy download en_core_web_sm
```

### Step 3: Set Up Groq API Key

Get your API key from [Groq Console](https://console.groq.com/):

```bash
# Option 1: Export in terminal
export GRAPHRAG_API_KEY="your-groq-api-key"

# Option 2: Create .env file (recommended)
echo 'GRAPHRAG_API_KEY=your-groq-api-key' > .env
```

### Step 4: Install and Run Ollama

Install Ollama from [ollama.ai](https://ollama.ai/), then:

```bash
# Pull the embedding model
ollama pull nomic-embed-text

# Start Ollama server (runs in background)
ollama serve
```

**Verify Ollama is running:**
```bash
curl http://localhost:11434/api/tags
# Should return list of models including nomic-embed-text
```

---

## Running Searches

With the pre-built indexes, you can run searches directly:

### Local Search
Best for specific questions about entities and their relationships:
```bash
graphrag query --root . --method local --query "Who is Scrooge?"
```

### Global Search
Best for broad questions requiring understanding of the entire corpus:
```bash
graphrag query --root . --method global --query "What are the main themes of the story?"
```

### Drift Search
Combines local and global search strategies:
```bash
graphrag query --root . --method drift --query "How does Scrooge change throughout the story?"
```

### Basic Search
Simple semantic search over text units:
```bash
graphrag query --root . --method basic --query "Describe the Ghost of Christmas Past"
```

### Using the Query Script
A convenience script is provided:
```bash
chmod +x query.sh
./query.sh "Who is Bob Cratchit?"
```

---

## File Structure

### Files to Keep (tracked in git)

```
graphrag_quickstart/
├── INSTRUCTION.md          # This file
├── requirements.txt        # Python dependencies
├── settings.yaml           # GraphRAG configuration
├── query.sh                # Query convenience script
├── input/
│   └── book.txt            # Source document
├── prompts/                # LLM prompt templates
│   ├── extract_graph.txt
│   ├── summarize_descriptions.txt
│   ├── community_report_graph.txt
│   ├── community_report_text.txt
│   ├── local_search_system_prompt.txt
│   ├── global_search_map_system_prompt.txt
│   ├── global_search_reduce_system_prompt.txt
│   ├── global_search_knowledge_system_prompt.txt
│   ├── drift_search_system_prompt.txt
│   ├── drift_reduce_prompt.txt
│   └── basic_search_system_prompt.txt
└── output/                 # Pre-built indexes (IMPORTANT!)
    ├── documents.parquet
    ├── text_units.parquet
    ├── entities.parquet
    ├── relationships.parquet
    ├── communities.parquet
    ├── community_reports.parquet
    ├── context.json
    ├── stats.json
    └── lancedb/            # Vector embeddings
        ├── default-entity-description.lance/
        ├── default-community-full_content.lance/
        └── default-text_unit-text.lance/
```

### Files Ignored (not tracked in git)

```
graphrag_quickstart/
├── venv/                   # Virtual environment
├── .venv/                  # Alternative venv name
├── cache/                  # GraphRAG cache
├── logs/                   # Indexing logs
└── .env                    # API keys (NEVER commit!)
```

---

## Re-indexing (Optional)

Only needed if you modify the input documents or want to rebuild:

```bash
# Ensure venv is activated and Ollama is running
source venv/bin/activate

# Clear existing outputs
rm -rf output cache logs

# Run indexing
graphrag index --root .
```

**Note:** Indexing takes approximately 24 minutes for this corpus.

---

## Troubleshooting

### "Connection refused" or Ollama errors

```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# If not, start it
ollama serve

# Verify model is available
ollama list  # Should show nomic-embed-text
```

### "API key" errors

```bash
# Check if key is set
echo $GRAPHRAG_API_KEY

# If empty, set it
export GRAPHRAG_API_KEY="your-key"

# Or source from .env
source .env
```

### Missing vector store / LanceDB errors

```bash
# Restore from git if indexes were deleted
git checkout HEAD -- output/lancedb/
```

### Module not found errors

```bash
# Ensure venv is activated
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### Apple Silicon (M1/M2/M3) specific

```bash
# Verify native ARM64 Python
python3 -c "import platform; print(platform.machine())"
# Should output: arm64

# If issues persist, try reinstalling with:
pip install --upgrade --force-reinstall numpy pandas pyarrow
```

---

## Index Statistics

| Metric | Value |
|--------|-------|
| Total runtime | ~24 minutes |
| Documents | 1 (A Christmas Carol) |
| Extract graph | ~15 minutes |
| Community reports | ~8 minutes |
| Text embeddings | ~12 seconds |

---

## API Rate Limits

The configuration uses conservative rate limits for Groq free tier:

| Setting | Value |
|---------|-------|
| `tokens_per_minute` | 25,000 |
| `requests_per_minute` | 25 |
| `concurrent_requests` | 2 |
| `max_retries` | 10 |

Adjust in `settings.yaml` if you have a paid Groq plan.
