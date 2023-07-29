source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }

ruby '3.2.2'

gem 'rails'

gem 'sqlite3'
gem 'puma'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  gem 'debug'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'

  # for `bin/rails test`'s error
  # /vendor/bundle/3.0.2/ruby/3.0.0/gems/bootsnap-1.9.1/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:23:in `require': cannot load such file -- rexml/document (LoadError)
  gem 'rexml'

end

gem 'lograge'
gem 'sassc-rails'
gem 'net-smtp'
gem 'net-pop' # /vendor/bundle/3.1.0-preview1/ruby/3.1.0/gems/bootsnap-1.9.3/lib/bootsnap/load_path_cache/core_ext/kernel_require.rb:34:in `require': cannot load such file -- net/pop (LoadError)
gem 'net-imap' # ditto

gem 'prime'
