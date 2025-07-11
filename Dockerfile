ARG RUBY_VERSION=3.4.4
FROM rubylang/ruby:$RUBY_VERSION-noble

RUN \
      apt-get update -qq && \
      apt-get install -yq curl libsqlite3-dev build-essential golang pkg-config libyaml-dev apt-get clean && \
      rm -rf /var/lib/apt/lists/*

ENV \
      APP_HOME=/app \
      BUNDLE_PATH=/vendor/bundle/$RUBY_VERSION \
      RUBYOPT=--yjit

RUN gem install bundler:2.6.9

RUN mkdir $APP_HOME && chown ubuntu $APP_HOME
RUN mkdir -p $BUNDLE_PATH && chown ubuntu $BUNDLE_PATH
RUN mkdir -p /usr/local/include/ruby-$RUBY_VERSION/site_ruby && chown ubuntu /usr/local/include/ruby-$RUBY_VERSION/site_ruby # dirty hack just for digest gem's bug

USER ubuntu

WORKDIR $APP_HOME

COPY --chown=ubuntu Gemfile Gemfile.lock .ruby-version ./
RUN bundle config set --local path "${BUNDLE_PATH}"
RUN bundle install

EXPOSE ${PORT}

COPY --chown=ubuntu bin/ ./bin/
COPY --chown=ubuntu lib/ ./lib/
COPY --chown=ubuntu *.js Rakefile ./
COPY --chown=ubuntu config/ ./config/
COPY --chown=ubuntu app/assets/ ./app/assets/

COPY --chown=ubuntu . ./
RUN echo "${COMMIT_SHA}" > ./VERSION && cat ./VERSION

# tmp/pids/server.pid is just for docker-compose
RUN rm -f ./tmp/pids/server.pid

CMD ["bin/rails", "server", "--binding", "0.0.0.0"]
