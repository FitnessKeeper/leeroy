FROM ruby:2.1
MAINTAINER Tim Hartmann <tim.hartmann@runkeeper.com>

ENV ENVIRONMENT=production
RUN apt-get update
RUN apt-get install cmake unzip libgit2-21 -y
RUN mkdir -p /tmp/build && \
    wget https://releases.hashicorp.com/packer/0.12.0/packer_0.12.0_linux_amd64.zip &&  \
    unzip -d /bin packer_0.12.0_linux_amd64.zip
RUN mkdir -p /opt/leeroy
WORKDIR /opt/leeroy
COPY . /opt/leeroy
RUN bundle install --without=development --deployment
RUN leeroy env -d > .env
VOLUME /data
ENTRYPOINT ["leeroy"]
CMD ["help"]
