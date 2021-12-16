FROM ubuntu:18.04

ENV APP_HOME /var/local/ohcount

RUN apt-get update \
  && apt-get install -y ruby ruby-dev git libpcre3 libpcre3-dev libmagic-dev gperf gcc ragel swig \
  && cp /usr/include/x86_64-linux-gnu/ruby-2.5.0/ruby/config.h /usr/include/ruby-2.5.0/ruby/

# RUN mkdir -p /var/local/repos
# RUN apt-get install -y vim-tiny ranger

RUN mkdir -p $APP_HOME
COPY . $APP_HOME

RUN cd $APP_HOME && ./build

WORKDIR $APP_HOME
