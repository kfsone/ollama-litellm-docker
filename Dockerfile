# Ollama-Litellm Llama2 OpenAI proxy with nvidia gpu support
# Author: Oliver 'kfsone' Smith <oliver@kfs.org>, 2023/11/16
#
# This docker image provides an openai compatible API endpoint on port 11111.
#
# To cache the AI model, provide a volume for /root/.ollama.
#
# Example command-line to run:
#
#  docker run --gpus=all -d -p 11111:11111 -v llama2:/root/.ollama kfsone/ollama-litellm

#################### Layer 1
# Using the ollama docker image as a base, so we get nvidia support for free,
# install python3 with venv and pip.
#
FROM	ollama/ollama:latest as just-add-python

RUN		apt update && \
		apt install -qy \
			git curl wget \
			python3 python-is-python3 python3-venv python3-pip \
			&& \
		# Shrink the layer's footprint \
		apt autoclean && \
		rm -rf /var/lib/apt/lists/*


#################### Layer 2
# Grab litellm from source and install in-place, along with the requirements needed.
#
FROM    just-add-python AS litellm-from-source
RUN     git clone https://github.com/BerriAI/litellm.git /app && rm -rf /app/dist
WORKDIR /app
RUN		python -m venv /app/venv && \
        . /app/venv/bin/activate && \
        pip install --no-cache -r requirements.txt && \
		pip install --no-cache -e . && \
        deactivate


#################### Layer 3
# Set up the environment and copy over neccessary files.
#
FROM    litellm-from-source AS final

# Make the LiteLLM port default to 11111 but let --build-arg override it.
ARG     LITELLM_PORT=11111
ENV		LITELLM_PORT=$LITELLM_PORT
EXPOSE	$LITELLM_PORT

# These need to be in the environment every run, so lets put them there.
ENV     OPENAI_API_KEY="none"
ENV		OPENAI_API_BASE="http://localhost:11434"


# startup wrapper script, runs ollama and litellm
COPY    start.sh .
# describes the model to use
COPY	ollama.yaml .
# Make the start script executable.
RUN     chmod +x start.sh

# And make the startup script our entry point.
ENTRYPOINT [ "/app/start.sh" ]
