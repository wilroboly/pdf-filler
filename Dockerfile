FROM debian:stretch-slim
LABEL maintainer William Roboly

ENV PATH_TO_PDFTK /usr/bin/pdftk
ARG CERT_FILENAME

RUN apt-get update && apt-get install -y \
  ruby \
  bundler \
  zlib1g-dev \
  ca-certificates \
  pdftk \
  curl \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/app
WORKDIR /usr/app

#TODO: Place this in an ENTRYPOINT script.
COPY ./ca-certificate/$CERT_FILENAME /usr/local/share/ca-certificates/
RUN /usr/sbin/update-ca-certificates

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app

RUN useradd -d /usr/app webadm
RUN chown -R webadm:webadm /usr/app
USER webadm

VOLUME /usr/app

CMD ruby app.rb -p 4567  -o 0.0.0.0
