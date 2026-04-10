# frozen_string_literal: true

require 'uri'
require_relative 'uri_kit/version'

module Philiprehberger
  module UriKit
    class Error < StandardError; end

    # Parsed URL wrapper with mutation methods
    class Url
      # @param url_string [String] the URL to parse
      def initialize(url_string)
        @uri = ::URI.parse(url_string.to_s.strip)
      rescue ::URI::InvalidURIError => e
        raise Error, "Invalid URL: #{e.message}"
      end

      # Add a query parameter
      #
      # @param key [String] parameter name
      # @param val [String] parameter value
      # @return [Url] self for chaining
      def add_param(key, val)
        current = params
        current[key.to_s] = val.to_s
        @uri.query = encode_params(current)
        self
      end

      # Remove a query parameter
      #
      # @param key [String] parameter name to remove
      # @return [Url] self for chaining
      def remove_param(key)
        current = params
        current.delete(key.to_s)
        @uri.query = current.empty? ? nil : encode_params(current)
        self
      end

      # Get all query parameters as a hash
      #
      # @return [Hash<String, String>] parameter key-value pairs
      def params
        return {} if @uri.query.nil? || @uri.query.empty?

        @uri.query.split('&').each_with_object({}) do |pair, hash|
          key, value = pair.split('=', 2)
          hash[::URI.decode_www_form_component(key)] = ::URI.decode_www_form_component(value || '')
        end
      end

      # Normalize the URL (lowercase scheme/host, remove default ports, sort params)
      #
      # @return [Url] self for chaining
      def normalize
        @uri.scheme = @uri.scheme&.downcase
        @uri.host = @uri.host&.downcase
        remove_default_port
        sort_params
        @uri.path = '/' if @uri.path.empty? && @uri.host
        @uri.fragment = nil if @uri.fragment && @uri.fragment.empty?
        self
      end

      # Get the registered domain (host without subdomain)
      #
      # @return [String, nil] the domain
      def domain
        return nil unless @uri.host

        parts = @uri.host.split('.')
        return @uri.host if parts.length <= 2

        parts.last(2).join('.')
      end

      # Get the subdomain portion
      #
      # @return [String, nil] the subdomain
      def subdomain
        return nil unless @uri.host

        parts = @uri.host.split('.')
        return nil if parts.length <= 2

        parts[0...-2].join('.')
      end

      # Append a path segment, handling leading/trailing slashes correctly
      #
      # @param segment [String] the path segment to append
      # @return [Url] a new Url with the appended path
      def append_path(segment)
        current = @uri.path.chomp('/')
        clean_segment = segment.to_s.sub(%r{^/}, '')
        new_path = "#{current}/#{clean_segment}"
        build_with(path: new_path)
      end

      # Get path segments as an array
      #
      # @return [Array<String>] non-empty path segments
      def path_segments
        @uri.path.split('/').reject(&:empty?)
      end

      # Replace the entire path
      #
      # @param new_path [String] the new path
      # @return [Url] a new Url with the replaced path
      def replace_path(new_path)
        normalized = new_path.to_s.start_with?('/') ? new_path.to_s : "/#{new_path}"
        build_with(path: normalized)
      end

      # Add multiple query parameters at once
      #
      # @param hash [Hash] parameters to add
      # @return [Url] a new Url with the added parameters
      def add_params(hash)
        merged = params.merge(hash.transform_keys(&:to_s).transform_values(&:to_s))
        new_url = build_with(query: nil)
        new_url.instance_variable_get(:@uri).query = encode_params(merged) unless merged.empty?
        new_url
      end

      # Remove all query parameters
      #
      # @return [Url] a new Url with no query parameters
      def clear_params
        build_with(query: nil)
      end

      # Get the base URL (scheme + host + port only)
      #
      # @return [String] the base URL string
      def base_url
        base = "#{@uri.scheme}://#{@uri.host}"
        base += ":#{@uri.port}" if @uri.port && !default_port?
        base
      end

      # @return [String, nil] the URL scheme (e.g. "https")
      def scheme
        @uri.scheme
      end

      # @return [String, nil] the hostname
      def host
        @uri.host
      end

      # @return [Integer, nil] the port number
      def port
        @uri.port
      end

      # @return [String] the path component
      def path
        @uri.path
      end

      # @return [String, nil] the raw query string
      def query
        @uri.query
      end

      # @return [String, nil] the fragment
      def fragment
        @uri.fragment
      end

      # @return [String] the full URL string
      def to_s
        @uri.to_s
      end

      # Value equality based on string representation
      #
      # @param other [Object] object to compare
      # @return [Boolean]
      def ==(other)
        other.is_a?(self.class) && to_s == other.to_s
      end

      alias eql? ==

      # @return [Integer] hash code consistent with eql?
      def hash
        to_s.hash
      end

      private

      def encode_params(hash)
        hash.map { |k, v| "#{::URI.encode_www_form_component(k)}=#{::URI.encode_www_form_component(v)}" }.join('&')
      end

      def remove_default_port
        return unless @uri.port

        default_ports = { 'http' => 80, 'https' => 443, 'ftp' => 21 }
        @uri.port = nil if @uri.port == default_ports[@uri.scheme]
      end

      def sort_params
        return if @uri.query.nil? || @uri.query.empty?

        sorted = params.sort_by { |k, _| k }
        @uri.query = encode_params(sorted.to_h)
      end

      def default_port?
        default_ports = { 'http' => 80, 'https' => 443, 'ftp' => 21 }
        @uri.port == default_ports[@uri.scheme]
      end

      def build_with(overrides)
        uri_copy = @uri.dup
        overrides.each { |key, value| uri_copy.send(:"#{key}=", value) }
        self.class.new(uri_copy.to_s)
      end
    end

    # Parse a URL string
    #
    # @param url [String] URL to parse
    # @return [Url] parsed URL object
    def self.parse(url)
      Url.new(url)
    end

    # Build a URL from components
    #
    # @param host [String] hostname
    # @param path [String] URL path
    # @param params [Hash] query parameters
    # @param scheme [String] URL scheme
    # @return [Url] built URL object
    def self.build(host:, path: '/', params: {}, scheme: 'https')
      query = if params.empty?
                nil
              else
                params.map do |k, v|
                  "#{::URI.encode_www_form_component(k)}=#{::URI.encode_www_form_component(v)}"
                end.join('&')
              end

      uri = ::URI::Generic.build(
        scheme: scheme,
        host: host,
        path: path.start_with?('/') ? path : "/#{path}",
        query: query
      )

      Url.new(uri.to_s)
    end

    # Join a base URL with a relative path
    #
    # @param base [String] base URL
    # @param relative [String] relative path
    # @return [Url] joined URL
    def self.join(base, relative)
      base_uri = ::URI.parse(base.to_s)
      joined = base_uri.merge(relative.to_s)
      Url.new(joined.to_s)
    rescue ::URI::InvalidURIError => e
      raise Error, "Invalid URL: #{e.message}"
    end
  end
end
