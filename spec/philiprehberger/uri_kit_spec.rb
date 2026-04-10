# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::UriKit do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses a valid URL' do
      url = described_class.parse('https://example.com/path?key=val')
      expect(url.to_s).to eq('https://example.com/path?key=val')
    end

    it 'raises Error for invalid URL' do
      expect { described_class.parse('ht tp://bad url') }.to raise_error(described_class::Error)
    end
  end

  describe Philiprehberger::UriKit::Url do
    describe '#add_param' do
      it 'adds a parameter to a URL without query' do
        url = described_class.new('https://example.com/path')
        url.add_param('key', 'value')
        expect(url.to_s).to eq('https://example.com/path?key=value')
      end

      it 'adds a parameter to a URL with existing query' do
        url = described_class.new('https://example.com?a=1')
        url.add_param('b', '2')
        expect(url.params).to eq('a' => '1', 'b' => '2')
      end

      it 'overwrites an existing parameter' do
        url = described_class.new('https://example.com?a=1')
        url.add_param('a', '2')
        expect(url.params).to eq('a' => '2')
      end

      it 'returns self for chaining' do
        url = described_class.new('https://example.com')
        result = url.add_param('a', '1')
        expect(result).to be(url)
      end
    end

    describe '#remove_param' do
      it 'removes an existing parameter' do
        url = described_class.new('https://example.com?a=1&b=2')
        url.remove_param('a')
        expect(url.params).to eq('b' => '2')
      end

      it 'clears query when last param removed' do
        url = described_class.new('https://example.com?a=1')
        url.remove_param('a')
        expect(url.to_s).to eq('https://example.com')
      end

      it 'does nothing for nonexistent parameter' do
        url = described_class.new('https://example.com?a=1')
        url.remove_param('b')
        expect(url.params).to eq('a' => '1')
      end
    end

    describe '#params' do
      it 'returns empty hash when no query' do
        url = described_class.new('https://example.com')
        expect(url.params).to eq({})
      end

      it 'parses multiple parameters' do
        url = described_class.new('https://example.com?a=1&b=2&c=3')
        expect(url.params).to eq('a' => '1', 'b' => '2', 'c' => '3')
      end

      it 'decodes URL-encoded values' do
        url = described_class.new('https://example.com?name=hello+world')
        expect(url.params['name']).to eq('hello world')
      end
    end

    describe '#normalize' do
      it 'lowercases scheme and host' do
        url = described_class.new('HTTP://EXAMPLE.COM/Path')
        url.normalize
        expect(url.to_s).to eq('http://example.com/Path')
      end

      it 'removes default port for http' do
        url = described_class.new('http://example.com:80/path')
        url.normalize
        expect(url.to_s).not_to include(':80')
      end

      it 'removes default port for https' do
        url = described_class.new('https://example.com:443/path')
        url.normalize
        expect(url.to_s).not_to include(':443')
      end

      it 'keeps non-default ports' do
        url = described_class.new('https://example.com:8080/path')
        url.normalize
        expect(url.to_s).to include(':8080')
      end

      it 'sorts query parameters' do
        url = described_class.new('https://example.com?z=3&a=1&m=2')
        url.normalize
        expect(url.to_s).to eq('https://example.com/?a=1&m=2&z=3')
      end
    end

    describe '#domain' do
      it 'returns domain for simple host' do
        url = described_class.new('https://example.com')
        expect(url.domain).to eq('example.com')
      end

      it 'returns domain from subdomain URL' do
        url = described_class.new('https://www.blog.example.com')
        expect(url.domain).to eq('example.com')
      end

      it 'returns nil when no host' do
        url = described_class.new('/relative/path')
        expect(url.domain).to be_nil
      end
    end

    describe '#subdomain' do
      it 'returns subdomain' do
        url = described_class.new('https://www.example.com')
        expect(url.subdomain).to eq('www')
      end

      it 'returns nested subdomains' do
        url = described_class.new('https://api.v2.example.com')
        expect(url.subdomain).to eq('api.v2')
      end

      it 'returns nil when no subdomain' do
        url = described_class.new('https://example.com')
        expect(url.subdomain).to be_nil
      end
    end

    describe '#append_path' do
      it 'appends a segment to an existing path' do
        url = described_class.new('https://example.com/api')
        result = url.append_path('users')
        expect(result.to_s).to eq('https://example.com/api/users')
      end

      it 'handles leading slash in segment' do
        url = described_class.new('https://example.com/api')
        result = url.append_path('/users')
        expect(result.to_s).to eq('https://example.com/api/users')
      end

      it 'handles trailing slash in base path' do
        url = described_class.new('https://example.com/api/')
        result = url.append_path('users')
        expect(result.to_s).to eq('https://example.com/api/users')
      end

      it 'handles both leading and trailing slashes' do
        url = described_class.new('https://example.com/api/')
        result = url.append_path('/users')
        expect(result.to_s).to eq('https://example.com/api/users')
      end

      it 'returns a new Url (immutable)' do
        url = described_class.new('https://example.com/api')
        result = url.append_path('users')
        expect(result).not_to be(url)
        expect(url.to_s).to eq('https://example.com/api')
      end

      it 'appends to empty path' do
        url = described_class.new('https://example.com')
        result = url.append_path('users')
        expect(result.to_s).to eq('https://example.com/users')
      end

      it 'appends to root path' do
        url = described_class.new('https://example.com/')
        result = url.append_path('users')
        expect(result.to_s).to eq('https://example.com/users')
      end
    end

    describe '#path_segments' do
      it 'returns segments for a typical path' do
        url = described_class.new('https://example.com/api/v2/users')
        expect(url.path_segments).to eq(%w[api v2 users])
      end

      it 'returns empty array for empty path' do
        url = described_class.new('https://example.com')
        expect(url.path_segments).to eq([])
      end

      it 'returns empty array for root path' do
        url = described_class.new('https://example.com/')
        expect(url.path_segments).to eq([])
      end

      it 'ignores trailing slashes' do
        url = described_class.new('https://example.com/api/users/')
        expect(url.path_segments).to eq(%w[api users])
      end

      it 'handles encoded segments' do
        url = described_class.new('https://example.com/path/hello%20world')
        expect(url.path_segments).to eq(%w[path hello%20world])
      end
    end

    describe '#replace_path' do
      it 'replaces the entire path' do
        url = described_class.new('https://example.com/old/path')
        result = url.replace_path('/new/path')
        expect(result.to_s).to eq('https://example.com/new/path')
      end

      it 'adds leading slash if missing' do
        url = described_class.new('https://example.com/old')
        result = url.replace_path('new')
        expect(result.to_s).to eq('https://example.com/new')
      end

      it 'returns a new Url (immutable)' do
        url = described_class.new('https://example.com/old')
        result = url.replace_path('/new')
        expect(result).not_to be(url)
        expect(url.to_s).to eq('https://example.com/old')
      end

      it 'preserves query and fragment' do
        url = described_class.new('https://example.com/old?a=1#frag')
        result = url.replace_path('/new')
        expect(result.to_s).to eq('https://example.com/new?a=1#frag')
      end
    end

    describe '#add_params' do
      it 'adds multiple parameters at once' do
        url = described_class.new('https://example.com/path')
        result = url.add_params('a' => '1', 'b' => '2')
        expect(result.params).to eq('a' => '1', 'b' => '2')
      end

      it 'merges with existing parameters' do
        url = described_class.new('https://example.com/path?x=0')
        result = url.add_params('a' => '1')
        expect(result.params).to eq('x' => '0', 'a' => '1')
      end

      it 'overwrites existing keys' do
        url = described_class.new('https://example.com?a=1')
        result = url.add_params('a' => '99')
        expect(result.params).to eq('a' => '99')
      end

      it 'handles symbol keys' do
        url = described_class.new('https://example.com')
        result = url.add_params(page: 1, limit: 10)
        expect(result.params).to eq('page' => '1', 'limit' => '10')
      end

      it 'returns a new Url (immutable)' do
        url = described_class.new('https://example.com')
        result = url.add_params('a' => '1')
        expect(result).not_to be(url)
        expect(url.params).to eq({})
      end
    end

    describe '#clear_params' do
      it 'removes all query parameters' do
        url = described_class.new('https://example.com/path?a=1&b=2')
        result = url.clear_params
        expect(result.params).to eq({})
        expect(result.to_s).to eq('https://example.com/path')
      end

      it 'returns a new Url (immutable)' do
        url = described_class.new('https://example.com?a=1')
        result = url.clear_params
        expect(result).not_to be(url)
        expect(url.params).to eq('a' => '1')
      end

      it 'handles URL with no params' do
        url = described_class.new('https://example.com/path')
        result = url.clear_params
        expect(result.to_s).to eq('https://example.com/path')
      end
    end

    describe '#base_url' do
      it 'returns scheme and host' do
        url = described_class.new('https://example.com/path?a=1#frag')
        expect(url.base_url).to eq('https://example.com')
      end

      it 'includes non-default port' do
        url = described_class.new('https://example.com:8080/path')
        expect(url.base_url).to eq('https://example.com:8080')
      end

      it 'excludes default https port' do
        url = described_class.new('https://example.com:443/path')
        expect(url.base_url).to eq('https://example.com')
      end

      it 'excludes default http port' do
        url = described_class.new('http://example.com:80/path')
        expect(url.base_url).to eq('http://example.com')
      end

      it 'works with http scheme' do
        url = described_class.new('http://example.com/path')
        expect(url.base_url).to eq('http://example.com')
      end
    end

    describe 'component accessors' do
      let(:url) { described_class.new('https://example.com:8080/api?key=val#section') }

      it '#scheme returns the scheme' do
        expect(url.scheme).to eq('https')
      end

      it '#host returns the host' do
        expect(url.host).to eq('example.com')
      end

      it '#port returns the port' do
        expect(url.port).to eq(8080)
      end

      it '#path returns the path' do
        expect(url.path).to eq('/api')
      end

      it '#query returns the raw query string' do
        expect(url.query).to eq('key=val')
      end

      it '#fragment returns the fragment' do
        expect(url.fragment).to eq('section')
      end

      it 'returns nil for missing components' do
        bare = described_class.new('https://example.com/path')
        expect(bare.query).to be_nil
        expect(bare.fragment).to be_nil
      end
    end

    describe 'equality' do
      it 'considers two Urls with the same string equal' do
        a = described_class.new('https://example.com/path')
        b = described_class.new('https://example.com/path')
        expect(a).to eq(b)
      end

      it 'considers different URLs not equal' do
        a = described_class.new('https://example.com/a')
        b = described_class.new('https://example.com/b')
        expect(a).not_to eq(b)
      end

      it 'is not equal to non-Url objects' do
        url = described_class.new('https://example.com')
        expect(url).not_to eq('https://example.com')
      end

      it 'supports eql? for hash key usage' do
        a = described_class.new('https://example.com')
        b = described_class.new('https://example.com')
        expect(a).to eql(b)
        expect(a.hash).to eq(b.hash)
      end

      it 'deduplicates in arrays via uniq' do
        a = described_class.new('https://example.com')
        b = described_class.new('https://example.com')
        expect([a, b].uniq.size).to eq(1)
      end
    end

    describe '#to_s' do
      it 'returns the full URL' do
        url = described_class.new('https://example.com/path?q=1#frag')
        expect(url.to_s).to eq('https://example.com/path?q=1#frag')
      end
    end
  end

  describe '.build' do
    it 'builds a URL from components' do
      url = described_class.build(host: 'example.com', path: '/api', params: { 'key' => 'val' })
      expect(url.to_s).to eq('https://example.com/api?key=val')
    end

    it 'defaults to https scheme' do
      url = described_class.build(host: 'example.com')
      expect(url.to_s).to start_with('https://')
    end

    it 'builds with custom scheme' do
      url = described_class.build(host: 'example.com', scheme: 'http')
      expect(url.to_s).to start_with('http://')
    end

    it 'builds with empty params' do
      url = described_class.build(host: 'example.com', path: '/test')
      expect(url.to_s).to eq('https://example.com/test')
    end

    it 'adds leading slash to path if missing' do
      url = described_class.build(host: 'example.com', path: 'test')
      expect(url.to_s).to include('/test')
    end
  end

  describe '.join' do
    it 'joins base and relative URL' do
      url = described_class.join('https://example.com/base/', 'page.html')
      expect(url.to_s).to eq('https://example.com/base/page.html')
    end

    it 'joins with absolute relative path' do
      url = described_class.join('https://example.com/base/', '/other')
      expect(url.to_s).to eq('https://example.com/other')
    end

    it 'handles parent directory references' do
      url = described_class.join('https://example.com/a/b/', '../c')
      expect(url.to_s).to eq('https://example.com/a/c')
    end
  end
end
