FROM ruby:2.7.0
COPY lib .
COPY bin .
COPY Gemfile .
RUN bundle install
ENTRYPOINT ["ruby", "bin/uwallet.rb"]