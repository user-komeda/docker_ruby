FROM almalinux:9-minimal AS builder

ARG RUBY_VERSION=4.0.5
ARG LIBYAML_VERSION=0.2.5

RUN microdnf -y install gcc make wget tar bzip2 \
    openssl-devel readline-devel zlib-devel libffi-devel && \
    microdnf clean all

WORKDIR /tmp

RUN wget https://pyyaml.org/download/libyaml/yaml-${LIBYAML_VERSION}.tar.gz && \
    tar -xzf yaml-${LIBYAML_VERSION}.tar.gz && cd yaml-${LIBYAML_VERSION} && \
    ./configure --prefix=/opt/libyaml && make && make install

RUN wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-${RUBY_VERSION}.tar.gz && \
    tar -xzf ruby-${RUBY_VERSION}.tar.gz && cd ruby-${RUBY_VERSION} && \
    ./configure --disable-install-doc --prefix=/usr/local --with-libyaml-dir=/opt/libyaml && \
    make -j$(nproc) && make install

RUN gem install bundler --no-document