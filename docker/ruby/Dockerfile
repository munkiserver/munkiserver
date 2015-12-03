FROM munkiserver/externals:latest

ENV RUBY_VERSION 2.2.2

ENV RUBY_BUILD_HOST https://github.com/sstephenson/ruby-build/archive/
ENV RUBY_CONFIGURE_OPTS --disable-install-doc
ENV RUBY_BUILD_VERSION 20151028

# Setup build environment
ENV BUILD_DIR /var/build
RUN mkdir $BUILD_DIR
WORKDIR $BUILD_DIR

# Download ruby-build
ADD $RUBY_BUILD_HOSTv$RUBY_BUILD_VERSION.tar.gz $BUILD_DIR/

RUN tar vxzf v$RUBY_BUILD_VERSION.tar.gz
RUN ./ruby-build-$RUBY_BUILD_VERSION/install.sh

# install ruby
RUN ruby-build -v $RUBY_VERSION /usr/local

RUN rm -rf $BUILD_DIR
