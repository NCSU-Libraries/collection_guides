source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.8'

gem "sprockets", ">=2.11.3"

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~>4.0.4'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'archivesspace-api-utility', :git => "git@github.com:trevorthornton/archivesspace-api-utility.git"


gem 'compass-rails', '>= 2.0.2'
# gem 'foundation-rails', '~> 5.5.2.1'
gem 'foundation-rails', '< 6.0'
gem 'modernizr-rails'
gem 'font-awesome-sass', '~>4.1.0'
# gem 'ncsul_web', git: 'git@github.ncsu.edu:ncsu-libraries/ncsul_web-rails.git'

gem 'rsolr'
gem 'will_paginate'
gem 'foundation-will_paginate'
gem 'nokogiri', '~> 1.6.7.1'
gem 'truncate_html'
gem 'chronic'
gem 'newrelic_rpm'

gem 'whenever', :require => false

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'thin'
  gem 'guard-livereload'
  gem 'quiet_assets'

  gem 'annotate'

  # For testing
  gem 'rspec-rails', '>= 3.3.0'
  gem 'factory_girl_rails', "~> 4.0"
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
