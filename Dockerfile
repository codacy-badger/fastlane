FROM python:3.7.2-slim-stretch

RUN apt-get update -y && apt-get install -y --no-install-recommends curl=7.52.1-5+deb9u8 make=4.1-9.1 \
                                                 software-properties-common=0.96.20.2-1 \
                                                 build-essential=12.3 \
                                                 git=1:2.11.0-3+deb9u4 \
                      && apt-get clean \
                      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home
ENV HOME="/home"
WORKDIR /home
RUN bash -c 'curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python'
ENV PATH="${HOME}/.poetry/bin:${PATH}"
RUN poetry --version

RUN mkdir -p /app
WORKDIR /app
COPY . /app
RUN poetry install --no-dev
RUN pip install honcho==1.0.1
RUN echo "Verifying fastlane version..." && fastlane version

ENV REDIS_URL "redis://redis:6379/0"
ENV DOCKER_HOSTS "[{\"match\": \"\", \"hosts\": [\"localhost:2376\"], \"maxRunning\":2}]"
ENV MONGODB_CONFIG "{\"host\": \"mongodb://mongo:27017/fastlane\", \"db\": \"fastlane\", \"serverSelectionTimeoutMS\": 100, \"connect\": false}"
RUN env

CMD honcho --no-colour start
