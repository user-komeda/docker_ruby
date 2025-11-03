FROM almalinux:9-minimal AS builder

# 開発ツール・依存ライブラリ
RUN microdnf -y install gcc make wget tar bzip2 \
    openssl-devel readline-devel zlib-devel libffi-devel && \
    microdnf clean all

WORKDIR /tmp

# libyaml をソースからビルド
RUN wget https://pyyaml.org/download/libyaml/yaml-0.2.5.tar.gz && \
    tar -xzf yaml-0.2.5.tar.gz && cd yaml-0.2.5 && \
    ./configure --prefix=/opt/libyaml && make && make install


# Ruby 3.4.7 をビルド（libyaml を指定）
RUN wget https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.7.tar.gz && \
    tar -xzf ruby-3.4.7.tar.gz && cd ruby-3.4.7 && \
    ./configure --disable-install-doc --prefix=/usr/local --with-libyaml-dir=/opt/libyaml && \
    make -j$(nproc) && make install

ENV PATH="/opt/ruby/bin:$PATH"

RUN gem install bundler --no-document

