ARG COG_REPO
ARG COG_MODEL
ARG COG_VERSION

FROM r8.im/${COG_REPO}/${COG_MODEL}@sha256:${COG_VERSION}

ENV RUNPOD_REQUEST_TIMEOUT=600

# Install necessary packages and Python 3.10
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends software-properties-common curl git openssh-server && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends python3.10 python3.10-dev python3.10-distutils && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 &&\
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py

# Create a virtual environment
RUN python3 -m venv /opt/venv

# Install runpod and huggingface_hub
RUN /opt/venv/bin/pip install runpod huggingface_hub

# Download ACE-Step weights at build time to the default cache path
RUN /opt/venv/bin/python3 -c "\
from huggingface_hub import snapshot_download; \
snapshot_download(repo_id='ACE-Step/ACE-Step-v1-3.5B', local_dir='/root/.cache/ace-step/checkpoints')"

ADD src/handler.py /rp_handler.py

CMD ["/opt/venv/bin/python3", "-u", "/rp_handler.py"]