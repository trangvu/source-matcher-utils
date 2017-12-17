# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'source-matcher-utils/version'

Gem::Specification.new do |gem|
  gem.add_runtime_dependency 'ferret', '~> 0.11.8.7'
  gem.add_runtime_dependency 'rest-client'
  gem.add_runtime_dependency 'thor', '~> 0.19.0'
  gem.authors       = ['Trang Vu']
  gem.description   = 'Matching external job source with Jora source'
  gem.email         = ['trang.vu@jora.com']
  gem.executables   = 'source-matcher-utils'
  gem.files         = %w(source-matcher-utils.gemspec) +
    Dir['*.md', 'bin/*', 'lib/**/*.rb']
  gem.homepage      = 'https://github.com/trangvu/source-matcher-utils'
  gem.name          = 'source-matcher-utils'
  gem.require_paths = %w(lib)
  gem.summary       = gem.description
  gem.version       = SourceMatcherUtils::VERSION
end
