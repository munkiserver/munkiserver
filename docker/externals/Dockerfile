FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
# install the servers we need and any tools or libs used to build ruby
RUN apt-get update
RUN apt-get install -y gcc make openssl wget libssl-dev libreadline-dev zlib1g-dev nginx-light mysql-server redis-server libmysqlclient-dev

# clean up afterwards...
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
