FROM ruby:2-slim-bullseye AS jekyll

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v "~>1.0" && gem install bundler jekyll

EXPOSE 4000

WORKDIR $PWD

# ENTRYPOINT [ "jekyll" ]

# CMD [ "bundle", "exec", "jekyll", "serve", "--force_polling", "-H", "0.0.0.0", "-P", "4000" ]

CMD [ "bundle", "exec", "jekyll", "serve"]