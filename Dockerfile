FROM ruby:3.2.2

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -y nodejs yarn

RUN apt-get install -y postgresql-client

WORKDIR /app

COPY Gemfile* ./

RUN bundle install

# Copy the rest of the application code to the working directory
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
