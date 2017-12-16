FROM debian:jessie-slim
LABEL maintainer Jack Lucky <jack.lucky.iv@gmail.com

ENV LANG en_US.UTF-8
ENV HOME /root
ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PATH_TO_PDFTK /usr/bin/pdftk
# ENV RUBY_VERSION 1.9.3-p448
ENV RUBY_VERSION 1.9.3-p551

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN apt-get -q update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q -y install wget \
  && apt-get -q clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -O - https://github.com/sstephenson/rbenv/archive/master.tar.gz \
  | tar zxf - \
  && mv rbenv-master $HOME/.rbenv

RUN wget -O - https://github.com/sstephenson/ruby-build/archive/master.tar.gz \
  | tar zxf - \
  && mkdir -p $HOME/.rbenv/plugins \
  && mv ruby-build-master $HOME/.rbenv/plugins/ruby-build

RUN echo 'eval "$(rbenv init -)"' >> $HOME/.profile
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

RUN apt-get update -q \
  && apt-get -q -y install pdftk ca-certificates openssl \
  && apt-get -q -y install autoconf bison build-essential \
  libcurl4-openssl-dev libffi-dev libgdbm-dev libgdbm3 libncurses5-dev \
  libreadline6-dev libssl-dev libyaml-dev zlib1g-dev \
  && rbenv install $RUBY_VERSION \
  && rbenv global $RUBY_VERSION \
  && apt-get purge -y -q autoconf bison zlib1g-dev \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists

RUN gem install --no-ri --no-rdoc bundler
RUN rbenv rehash

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app
VOLUME /usr/app

CMD ruby app.rb -p 4567  -o 0.0.0.0
