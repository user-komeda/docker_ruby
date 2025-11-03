# =========================
# ① ビルドステージ
# =========================
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
    ./configure --disable-install-doc --prefix=/opt/ruby --with-libyaml-dir=/opt/libyaml && \
    make -j$(nproc) && make install

RUN /opt/ruby/bin/gem install json bigdecimal --no-document

# =========================
# ② 実行ステージ（軽量）
# =========================
FROM almalinux:9-minimal

# 実行に必要なランタイムライブラリ
RUN microdnf -y install openssl readline zlib libffi && microdnf clean all

# Ruby と libyaml をコピー
COPY --from=builder /opt/ruby /opt/ruby
COPY --from=builder /opt/libyaml /opt/libyaml



# Bundler をインストール
RUN gem install bundler --no-document

ENV GEM_PATH="/opt/ruby/lib/ruby/gems/3.4.0"
ENV PATH="/opt/ruby/bin:$PATH"

# 起動確認・常駐
CMD ["sh", "-c", "ruby -v && gem list bundler && tail -f /dev/null"]
