FROM jetbrains/teamcity-agent
MAINTAINER Denis Grotsev

RUN apt-get update
RUN apt-get install -y \
            postgresql-client \
      && rm -rf /var/lib/apt/lists/*
