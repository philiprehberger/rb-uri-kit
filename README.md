# philiprehberger-uri_kit

[![Tests](https://github.com/philiprehberger/rb-uri-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-uri-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-uri_kit.svg)](https://rubygems.org/gems/philiprehberger-uri_kit)
[![License](https://img.shields.io/github/license/philiprehberger/rb-uri-kit)](LICENSE)

URL manipulation with query parameter management and normalization

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-uri_kit"
```

Or install directly:

```bash
gem install philiprehberger-uri_kit
```

## Usage

```ruby
require "philiprehberger/uri_kit"

url = Philiprehberger::UriKit.parse('https://example.com/path?a=1')
url.add_param('b', '2')
url.remove_param('a')
url.params   # => {"b"=>"2"}
url.to_s     # => "https://example.com/path?b=2"
```

### Normalization

```ruby
url = Philiprehberger::UriKit.parse('HTTP://EXAMPLE.COM:80/path?z=3&a=1')
url.normalize
url.to_s  # => "http://example.com/path?a=1&z=3"
```

### Domain Extraction

```ruby
url = Philiprehberger::UriKit.parse('https://api.v2.example.com/data')
url.domain     # => "example.com"
url.subdomain  # => "api.v2"
```

### Building URLs

```ruby
url = Philiprehberger::UriKit.build(
  host: 'example.com',
  path: '/api/users',
  params: { 'page' => '1', 'limit' => '10' }
)
url.to_s  # => "https://example.com/api/users?page=1&limit=10"
```

### Joining URLs

```ruby
url = Philiprehberger::UriKit.join('https://example.com/base/', 'page.html')
url.to_s  # => "https://example.com/base/page.html"
```

## API

| Method | Description |
|--------|-------------|
| `UriKit.parse(url)` | Parse a URL string into a Url object |
| `UriKit.build(host:, path:, params:, scheme:)` | Build a URL from components |
| `UriKit.join(base, relative)` | Join a base URL with a relative path |
| `Url#add_param(key, val)` | Add or replace a query parameter |
| `Url#remove_param(key)` | Remove a query parameter |
| `Url#params` | Get all query parameters as a hash |
| `Url#normalize` | Normalize the URL |
| `Url#domain` | Get the registered domain |
| `Url#subdomain` | Get the subdomain portion |
| `Url#to_s` | Get the full URL string |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
