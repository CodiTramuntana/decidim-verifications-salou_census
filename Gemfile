# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gemspec

gem "rails", "5.2.1"

gem 'decidim', "~> 0.16.0"

group :development, :test do
  gem 'byebug', '~> 10.0', platform: :mri
  gem "bootsnap", require: true
  gem 'faker', '~> 1.8'
  gem 'listen'
end

group :development do
  gem 'letter_opener_web', '~> 1.3.3'
  gem 'web-console', '~> 3.5'
end
