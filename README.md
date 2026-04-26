# philiprehberger-uri_kit

[![Tests](https://github.com/philiprehberger/rb-uri-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-uri-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-uri_kit.svg)](https://rubygems.org/gems/philiprehberger-uri_kit)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-uri-kit)](https://github.com/philiprehberger/rb-uri-kit/commits/main)

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

### Path Manipulation

```ruby
url = Philiprehberger::UriKit.parse('https://example.com/api')

appended = url.append_path('users')
appended.to_s  # => "https://example.com/api/users"

url.path_segments  # => ["api"]

replaced = url.replace_path('/v2/items')
replaced.to_s  # => "https://example.com/v2/items"
```

### Query Helpers

```ruby
url = Philiprehberger::UriKit.parse('https://example.com/search?q=ruby')

with_params = url.add_params('page' => '1', 'limit' => '10')
with_params.to_s  # => "https://example.com/search?q=ruby&page=1&limit=10"

cleared = url.clear_params
cleared.to_s  # => "https://example.com/search"

tracking = Philiprehberger::UriKit.parse('https://example.com/p?utm_source=x&id=42')
tracking.keep_params('id').to_s  # => "https://example.com/p?id=42"
```

### Base URL

```ruby
url = Philiprehberger::UriKit.parse('https://example.com:8080/api/v2?key=val')
url.base_url  # => "https://example.com:8080"
```

### Component Accessors

```ruby
url = Philiprehberger::UriKit.parse('https://example.com:8080/api?key=val#section')
url.scheme    # => "https"
url.host      # => "example.com"
url.port      # => 8080
url.path      # => "/api"
url.query     # => "key=val"
url.fragment  # => "section"
```

### Equality

```ruby
a = Philiprehberger::UriKit.parse('https://example.com/path')
b = Philiprehberger::UriKit.parse('https://example.com/path')
a == b  # => true

# Works with Hash keys and arrays
set = [a, b].uniq  # => 1 element
```

### Joining URLs

```ruby
url = Philiprehberger::UriKit.join('https://example.com/base/', 'page.html')
url.to_s  # => "https://example.com/base/page.html"
```

### Origin and Host Comparison

```ruby
require "philiprehberger/uri_kit"

a = Philiprehberger::UriKit.parse('https://example.com/page')
b = Philiprehberger::UriKit.parse('https://example.com/other')
a.same_origin?(b)            # => true
a.same_host?('http://example.com')  # => true
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
| `Url#append_path(segment)` | Append a path segment, returns new Url |
| `Url#path_segments` | Get path segments as an array |
| `Url#replace_path(new_path)` | Replace the entire path, returns new Url |
| `Url#add_params(hash)` | Add multiple query parameters, returns new Url |
| `Url#clear_params` | Remove all query parameters, returns new Url |
| `Url#keep_params(*keys)` | Keep only the listed query params, drop the rest; returns new Url |
| `Url#base_url` | Get scheme + host + port as a string |
| `Url#scheme` | URL scheme (e.g. `"https"`) |
| `Url#host` | Hostname |
| `Url#port` | Port number |
| `Url#path` | Path component |
| `Url#query` | Raw query string |
| `Url#fragment` | Fragment identifier |
| `Url#to_s` | Get the full URL string |
| `Url#==` / `Url#eql?` | Value equality based on string representation |
| `Url#same_origin?(other)` | True when scheme, host, and effective port match (RFC 6454) |
| `Url#same_host?(other)` | True when only the host matches, case-insensitive |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-uri-kit)

🐛 [Report issues](https://github.com/philiprehberger/rb-uri-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-uri-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
