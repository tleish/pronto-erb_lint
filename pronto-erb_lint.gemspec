# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'pronto/erb_lint/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'pronto-erb_lint'
  s.version = Pronto::ERBLintVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'tleish'
  s.email = 'tleish@hotmail.com'
  s.homepage = 'https://github.com/tleish/pronto-erb_lint'
  s.summary = 'Pronto runner for ERB Lint, erb code analyzer'

  s.licenses = ['MIT']
  s.required_ruby_version = '>= 2.0.0'
  s.rubygems_version = '1.8.23'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    spec/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$}x
  end
  s.test_files = []
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_runtime_dependency('erb_lint', '~> 0.0.24')
  s.add_runtime_dependency('pronto', '~> 0.6.0')
  s.add_development_dependency('rake', '~> 12.0')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rspec-its', '~> 1.2')
end
