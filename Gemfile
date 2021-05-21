source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.6'

gem 'sprockets-rails'
# sprockets/es6 required for foundation but not included in dependencies -  may be added as a depnency in a future version
gem 'sprockets-es6', '>= 0.9.0'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
gem 'archivesspace-api-utility', git: 'https://github.com/NCSU-Libraries/archivesspace-api-utility.git'
gem 'compass-rails'
gem 'modernizr-rails'

gem 'foundation-rails'
gem 'font-awesome-sass'
gem 'foundation-will_paginate'
gem 'will_paginate'

gem 'rsolr'
# security vulnerabilities fix - https://github.com/NCSU-Libraries/collection_guides/security/dependabot/Gemfile.lock/nokogiri/open
gem "nokogiri", ">= 1.11.4"
gem 'truncate_html'
gem 'chronic'

gem 'whenever', :require => false

# security vulnerability fix - https://nvd.nist.gov/vuln/detail/CVE-2018-16468
gem "loofah", ">= 2.2.3"

# security vulnerabilities in rails-html-sanitizer 1.0.3
gem 'rails-html-sanitizer', '~> 1.0.4'
gem 'redis'
gem 'resque', require: 'resque/server'
gem 'resque-web', require: 'resque_web'
gem 'resque-scheduler'

gem 'net-ldap'

# Exception Notifications
gem 'exception_notification', '~> 4.2', '>= 4.2.2'
gem 'exception_notification-rake'


# https://nvd.nist.gov/vuln/detail/CVE-2019-16109
gem 'devise', '~> 4.7.1'

# https://github.com/rails/rails/security/advisories/GHSA-65cv-r6x7-79hv
# gem 'actionview', '~> 5.2.4.4'

# https://blog.jcoglan.com/2020/06/02/redos-vulnerability-in-websocket-extensions/
# gem 'websocket-extensions', '~> 0.1.5'

# https://github.com/advisories/GHSA-j6w9-fv6q-3q52
# gem "rack", ">= 2.2.3"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  # Use SQLite for development
  gem 'sqlite3'
  gem 'thin'
  gem 'guard-livereload'
  # gem 'quiet_assets'
  gem 'annotate'
  # For testing
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'database_cleaner', ">= 1.0.0"
  # Capistrano and friends
  gem 'capistrano', '~> 3.6'
  # rails specific capistrano funcitons
  gem 'capistrano-rails', '~> 1.2'
  # integrate bundler with capistrano
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]

# NC State only

gem 'devise_wolftech_authenticatable',
    git: "git@github.ncsu.edu:NCSU-Libraries/devise_wolftech_authenticatable.git"

gem 'ncsul_web', git: 'git@github.ncsu.edu:ncsu-libraries/ncsul_web-rails.git'
