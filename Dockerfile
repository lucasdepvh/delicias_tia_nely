FROM ruby:3.4.2-slim

WORKDIR /rails
ENV RAILS_ENV=production BUNDLE_WITHOUT="development:test"

RUN apt-get update -qq && apt-get install --no-install-recommends -y build-essential libsqlite3-dev libvips sqlite3 && rm -rf /var/lib/apt/lists/*
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
RUN bundle exec rails assets:precompile

RUN mkdir -p /rails/storage /rails/tmp/pids && chown -R 1000:1000 /rails
USER 1000:1000
EXPOSE 3000
ENTRYPOINT ["sh", "/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
