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
