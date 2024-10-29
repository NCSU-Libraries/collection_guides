FROM ruby:3.3-alpine

RUN mkdir -p /opt/collection_guides
WORKDIR /opt/collection_guides

EXPOSE 3000

ENV RAILS_ENV development

RUN gem install bundler

COPY Gemfile Gemfile.lock ./

RUN apk add --no-cache openssh-client git alpine-sdk shared-mime-info mariadb-dev sqlite-dev sqlite nodejs npm gcompat tzdata xz redis bash less

RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.ncsu.edu >> ~/.ssh/known_hosts

RUN --mount=type=ssh bundle install -j $(nproc)

CMD ["/bin/bash"]
