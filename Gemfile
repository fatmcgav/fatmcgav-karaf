source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.6.0'
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git', :ref => '891c5794fd'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem 'librarian-puppet', '~> 1.0.0'
  gem 'simplecov', :platforms => [:ruby_19, :ruby_20]
  gem 'coveralls', :platforms => [:ruby_19, :ruby_20] 
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker"
  gem "beaker-rspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
