# Ollama-LiteLLM Docker file

Dockerfile, start.sh and config for running ollama behind litellm in a single container

## Building

```
docker build --tag <what you want to call it> .
```


## Running

The image derives directly from ollama/ollama and layers litellm from source over it,
it starts `ollama serve` in the background, pulls the `llama2` model, and then starts
up a litellm proxy listening on port 11111.

### Minimum command line

This will run the container in the foreground, but if you just need the port open this
may be acceptable. It won't be able to use GPUs for the model.
```
docker run -p 11111:11111 kfsone/ollama-litellm-docker
```

### Recommended command line

Arguments uesd:
- `-d` runs the container detached (in the background),
; `--rm` will remove the container on completion,
- `--gpus=all` enables the container to use your nvidia gpus,
- `-p 11111:11111` allows access to the proxy on port 11111,
- `-v ollama:/root/.ollama` caches the model ollama pulls, saving bandwidth/startup time,
- `--name ollama-litellm` gives this container a meaningful name,
- `kfsone/ollama-litellm-docker` substitute with the --tag if you build your own

```
docker run -d --rm --gpus=all -p 11111:11111 -v ollama:/root/.ollama --name ollama-litellm kfsone/ollama-litellm-docker
```

# All credit to the Ollama and Litellm devs

I just wrote a Dockerfile.

