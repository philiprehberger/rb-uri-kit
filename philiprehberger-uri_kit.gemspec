# frozen_string_literal: true

require_relative 'lib/philiprehberger/uri_kit/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-uri_kit'
  spec.version = Philiprehberger::UriKit::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'URL manipulation with query parameter management and normalization'
  spec.description = 'Parse, build, and manipulate URLs with query parameter management, ' \
                     'normalization, domain extraction, and URL joining. Built on Ruby stdlib URI.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-uri_kit'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-uri-kit'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-uri-kit/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-uri-kit/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
