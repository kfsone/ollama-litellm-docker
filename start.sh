#! /bin/bash
set -euo pipefail  # bash strict mode

cd /app && . /app/venv/bin/activate

# Start ollama
ollama serve &
sleep 2
ollama pull llama2

echo "== Starting litellm. OPENAI_API_BASE=${OPENAI_API_BASE}, LITELLM_PORT=${LITELLM_PORT}"
litellm --config /app/ollama.yaml --model llama2 --api_base http://localhost:11434 --port ${LITELLM_PORT}

