source 'https://rubygems.org'

ruby '3.1.2'

gem 'archivesspace-api-utility', git: 'https://github.com/NCSU-Libraries/archivesspace-api-utility.git'

# NC State only

gem 'devise_wolftech_authenticatable',
    git: "git@github.ncsu.edu:NCSU-Libraries/devise_wolftech_authenticatable.git"

gem 'ncsul_web', git: 'git@github.ncsu.edu:ncsu-libraries/ncsul_web-rails.git'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.5.1'

gem 'sprockets-rails'
# sprockets/es6 required for foundation but not included in dependencies -  may be added as a depnency in a future version
gem 'sprockets-es6'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
# gem 'sass-rails'
gem 'sass-rails', '~> 5.0'
gem 'foundation-rails'
# gem 'font-awesome-sass'
gem 'font-awesome-sass', '< 6.0.0'
gem 'foundation-will_paginate'
gem 'will_paginate'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# gem 'compass-rails'
gem 'modernizr-rails'

gem 'rsolr'
# security vulnerabilities fix - https://github.com/NCSU-Libraries/collection_guides/security/dependabot/Gemfile.lock/nokogiri/open
gem 'truncate_html'
gem 'chronic'



gem 'whenever', :require => false


gem 'redis', '~> 4.0'
gem 'resque', '~> 2.1.0'
gem 'resque-web', require: 'resque_web'
gem 'resque-scheduler'
gem 'sinatra', '>= 3.0.4'

gem 'net-ldap'
gem "net-http"
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

# Exception Notifications
gem 'exception_notification'
gem 'exception_notification-rake'


# https://nvd.nist.gov/vuln/detail/CVE-2019-16109
gem 'devise'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end

group :development, :test do
  # Use Puma as the app server
  gem "puma"
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '>= 3.0.0'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  # Use SQLite for development
  gem 'sqlite3'
  # gem 'quiet_assets'
  gem 'annotate'
  # For testing
  gem 'rspec-rails'
  gem 'database_cleaner', ">= 1.0.0"
  gem 'factory_bot_rails'
  gem 'pry'
end


# Specify versions for depenedencies with security patches here
gem "nokogiri", '~> 1.14.3'
gem 'rails-html-sanitizer', '>= 1.4.4'
gem "rack", ">= 2.2.6.4"
gem 'loofah', '>= 2.19.1'
gem 'uri', '~> 0.12.2'
