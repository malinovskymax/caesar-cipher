source 'https://rubygems.org'

ruby '2.3.0'

gem 'rails', '4.2.6'

gem 'bower-rails'
# Objects serialization using Rails 5 approach
gem 'active_model_serializers', github: 'rails-api/active_model_serializers'
gem 'json'
# Manage environment easily
gem 'figaro'

## Assets
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# HTML preprocessor, see more: http://slim-lang.com/
gem 'slim'

## Scripts
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# Cache templates
gem 'angular-rails-templates'
# convert attribute names between underscore and camel case, and other useful features
gem 'angularjs-rails-resource'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development do
  gem 'spring'
  gem 'quiet_assets'
end

group :production do
  gem 'rails_12factor'
  gem 'rails_serve_static_assets'
  gem 'rails_stdout_logging'
end
