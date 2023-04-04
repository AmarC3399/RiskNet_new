source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem 'jquery-rails'

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'sdoc'
 gem 'sass-rails', '~> 6.0.0' 
 gem 'uglifier', '4.2.0'
 gem 'coffee-rails', '~> 5.0.0'
 gem 'json', '~>2.6.2'
 gem 'devise'
 #gem 'devise_security_extension'
 gem 'authority', '~>3.3.0'
 gem "rolify", '~> 6.0.0'
 gem 'haml-rails', '~> 2.1.0'
 gem "logstasher", '~> 2.1.5'
 #gem 'activerecord_any_of', '~> 1.4'
 gem 'wannabe_bool', '~> 0.7.1'
 gem 'i18n', "~> 1.12.0"
 gem 'font-awesome-rails', '~> 4.7.0.8'

 # these 3 gems are for dev and tests but moved here for the DEMO
#gem 'factory_girl_rails', '~> 4.9.0'
gem 'factory_bot', '~> 6.2.1'
gem 'database_cleaner', ' ~> 2.0.1'
gem 'ffaker', '~> 2.21.0'
# gem 'facter', '~> 2.1.0', require: false
# gem 'facter', '~> 2.4', '>= 2.4.4', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  gem 'figaro', '~> 1.2.0'
  gem 'rspec-rails', '= 6.0.1'
  gem 'minitest-spec-rails', '~> 6.2.0'
  gem 'shoulda-matchers', '~> 4.0.0'
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem "bullet", '~> 7.0.7'
  gem "commands",'~> 0.2.1'
  gem "phantomjs", ">= 2.1.1.0"
  gem "teaspoon", '~> 1.2.2'
  #gem 'spork-rails'
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'lol_dba', '~> 2.4.0'
  gem 'anbt-sql-formatter', '~> 0.1.0'
  #gem 'warbler', '~> 2.0.5'
  gem 'simplecov', "~> 0.22.0"
  gem 'simplecov-rcov', '~> 0.3.1'
  gem 'brakeman', '~> 5.4.0'
  gem 'ci_reporter_rspec'
  gem 'json_spec', '~> 1.1.5'
  gem 'pry'
  gem 'pry-nav'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

   gem 'guard-bundler', '~> 3.0.1'
   gem 'guard-rails', '~> 0.8.1'
  gem 'guard-rspec', '~> 4.7.3' 
  #gem 'quiet_assets', '~> 1.1.0'
  gem 'rb-fchange', '~> 0.0.6'
  gem 'rb-fsevent', '~> 0.10.1', :require => false
  gem 'rb-inotify', '~> 0.9.2', :require => false
  gem 'fuubar', '~> 2.5.1'
  gem 'awesome_print', '~> 1.9.2'
   #gem 'rubocop' ,'~>1.45.1'
  #gem 'meta_request' , '~> 0.7.3'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'email_spec', '~> 2.2.1'  
  # CI reporter for Jenkins.
  #gem 'minitest-reporters'  ,'~> 0.14.24'
  gem "shoulda", "~> 4.0.0"
  
 gem 'schema_plus'
 gem 'schema_validations', '~> 2.4.1'
 
 gem 'json-schema', '~> 3.0.0'

 gem 'deep_cloneable', '~> 3.2.0'

 gem 'acts_as_commentable', '~> 4.0.2'
 gem 'secure_headers', '6.5.0'
 gem 'foreman', '~> 0.87.2'
 gem 'country_select', '~> 8.0.1'
 gem "seedbank", '~> 0.5.0'
 gem  'ruby-progressbar', '~> 1.11.0'
 gem 'i18n-active_record', :git => 'https://github.com/svenfuchs/i18n-active_record.git', :require => 'i18n/active_record'
 gem 'indefinite_article', '~> 0.2.5'

 gem 'composite_primary_keys', '~>14.0.4' # git: 'https://RiskNetRealTime@dev.azure.com/RiskNetRealTime/composite_primary_keys/_git/composite_primary_keys', branch: 'ar_4.2.x'
 gem 'slop', '~> 4.9.3'
 # gem 'ai_failover_adapter', '1.1.0',  :git => 'http://PRODGITLAB/ai/db_failover_adapter.git'
 gem 'filewatch', '~> 0.9.0'
 gem 'exception_notification', '~> 4.5.0'
 gem 'iso_country_codes', '~>0.7.8'
 gem 'money', '~> 6.16.0'

 gem 'rake', '~> 13.0.6'
  
 gem 'prettify', '~> 0.0.1'
 gem 'active_record_union', '~> 1.3.0'
 gem 'jwt', '~> 2.7.0'
 gem 'jc-validates_timeliness', '~> 3.1.1'
 gem 'rubyzip', '~> 2.3.2'
 gem 'concurrent-ruby', '~> 1.1.10'

end

 #gem 'license', git: 'http://PRODGITLAB/ai/license.git', ref: '59831b91' 
 gem 'license', '~> 0.6.2 '

gem 'public_suffix', '~> 5.0.1'
gem 'parallel_tests', '~> 4.2.0'
 gem 'webpacker'