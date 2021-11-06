FROM ruby:2.7.0
COPY cli.rb .
COPY Gemfile .
RUN bundle install
ENTRYPOINT ["ruby", "cli.rb"]