# # buildでImageが以下から作成される
FROM ruby:2.7.2

RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /myprotein-price-bot
ENV APP_ROOT /myprotein-price-bot
WORKDIR $APP_ROOT

# #ホスト側からDocker側にGemfileをコピー
ADD ./Gemfile $APP_ROOT/Gemfile
ADD ./Gemfile.lock $APP_ROOT/Gemfile.lock

RUN bundle install
ADD . $APP_ROOT