ARG PYTORCH_TAG=2.3.0-cuda12.1-cudnn8-runtime
FROM pytorch/pytorch:${PYTORCH_TAG}

## Add System Dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get install --no-install-recommends -y \
        build-essential \
        git \
        wget libxrender1 libfontconfig1 libxtst6 libxi6 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

## Install some Python dependencies
RUN python -m pip install --no-cache-dir \
    pytest \
    requests \
    biopandas

## Change working directory
WORKDIR /app/alphafold

## Clone and install the package + requirements
ARG GIT_TAG=main
RUN git clone https://github.com/lucidrains/alphafold3-pytorch . --branch ${GIT_TAG} \
    # && git checkout main \
    && python -m pip install .

RUN echo '#!/usr/bin/env python' > /app/alphafold/scripts/temp.py && \
    cat /app/alphafold/scripts/cluster_pdb_mmcifs.py >> /app/alphafold/scripts/temp.py && \
    mv /app/alphafold/scripts/temp.py /app/alphafold/scripts/cluster_pdb_mmcifs.py && \
    chmod +x /app/alphafold/scripts/cluster_pdb_mmcifs.py

RUN echo '#!/usr/bin/env python' > /app/alphafold/scripts/temp.py && \
    cat /app/alphafold/scripts/filter_pdb_mmcifs.py >> /app/alphafold/scripts/temp.py && \
    mv /app/alphafold/scripts/temp.py /app/alphafold/scripts/filter_pdb_mmcifs.py && \
    chmod +x /app/alphafold/scripts/filter_pdb_mmcifs.py

ENV PATH=/app/alphafold/scripts/:$PATH

## Install packages required for jupyter
RUN python -m pip install ipython ipykernel

