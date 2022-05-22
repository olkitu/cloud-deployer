FROM debian:bullseye-slim

# Copy Python 3.9
COPY --from=python:3.9-slim-bullseye /usr/local/bin/python3.9 /usr/local/bin/python3.9 
COPY --from=python:3.9-slim-bullseye /usr/local/bin/python3.9-config /usr/local/bin/python3.9-config
COPY --from=python:3.9-slim-bullseye /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=python:3.9-slim-bullseye /usr/local/bin/pip3.9 /usr/local/bin/pip3.9
COPY --from=python:3.9-slim-bullseye /usr/local/lib/libpython3.9.so.1.0 /usr/local/lib/libpython3.9.so.1.0

# Copy Python 3.10
COPY --from=python:3.10-slim-bullseye /usr/local/bin/python3.10 /usr/local/bin/python3.10 
COPY --from=python:3.10-slim-bullseye /usr/local/bin/python3.10-config /usr/local/bin/python3.10-config
COPY --from=python:3.10-slim-bullseye /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=python:3.10-slim-bullseye /usr/local/bin/pip3.10 /usr/local/bin/pip3.10
COPY --from=python:3.10-slim-bullseye /usr/local/lib/libpython3.10.so.1.0 /usr/local/lib/libpython3.10.so.1.0

# Copy Python default version 3.10
COPY --from=python:3.10-slim-bullseye /usr/local/lib/libpython3.so /usr/local/lib/libpython3.so
COPY --from=python:3.10-slim-bullseye /usr/local/bin/python /usr/local/bin/python
COPY --from=python:3.10-slim-bullseye /usr/local/bin/pip3 /usr/local/bin/pip3

# Copy Docker binaries
COPY --from=docker:20.10 /usr/local/bin /usr/local/bin
COPY --from=docker:20.10 /usr/libexec/docker /usr/libexec/docker

RUN Arch="$(uname -m)" \
    && apt-get update && apt-get upgrade -y \
    && apt-get install -y jq curl unzip make git libsqlite3-0 apt-transport-https ca-certificates gnupg lsb-release \
    && pip3 --no-cache-dir install --upgrade pip \
    && pip3 --no-cache-dir install yq aws-sam-cli cfn-lint \
    && cd /tmp && curl -s "https://awscli.amazonaws.com/awscli-exe-linux-${Arch}.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && curl -Lo /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest \
    && chmod +x /usr/local/bin/ecs-cli \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg \
    && AZ_REPO=$(lsb_release -cs) \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && apt-get install google-cloud-cli azure-cli \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && python -v \
    && aws --version \
    && ecs-cli --version \
    && gcloud version \
    && az --version