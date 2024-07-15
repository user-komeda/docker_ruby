FROM almalinux:minimal

RUN mkdir /tmp_build

# Rails app lives here
WORKDIR /tmp_build
# Set production environmen

ENV NODE_VERSION 20.15.0
RUN microdnf -y install --enablerepo=crb tar make gcc xz python3 nodejs g++ zlib-devel openssl-devel readline-devel libffi-devel libyaml-devel
# Install packages needed to build gems
RUN curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"
RUN tar -xf "node-v$NODE_VERSION.tar.xz"
RUN cd "node-v$NODE_VERSION" && ./configure && make -j$(getconf _NPROCESSORS_ONLN) && make install
RUN corepack enable yarn
RUN yarn set version stable -f

# Install packages needed to build gems

RUN curl -O https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.4.tar.gz

RUN tar zxvf ruby-3.3.4.tar.gz

RUN cd /tmp_build/ruby-3.3.4 && ./configure &&  make -j$(getconf _NPROCESSORS_ONLN)&& make install

RUN rm -rf /tmp_build
RUN gem install bundler
