require 'timeout'
require 'logger'
require 'yajl'
require 'uri'
require 'yajl/version'
require 'yajl/http_stream'
require 'i18n'
require 'active_support'
require 'active_support/inflector'

module Geokit

  class GeokitError < StandardError; end
  class GeocoderServiceError < GeokitError; end
  class TimeoutError < GeocoderServiceError; end
  class InvalidResponseError < GeocoderServiceError; end
  class InvalidStatusCodeError < GeocoderServiceError; end
  class TooManyQueriesError < GeocoderServiceError; end

  module Geocoders
    @@request_timeout = nil
    @@google = 'REPLACE_WITH_YOUR_GOOGLE_KEY'
    @@logger = Logger.new(STDOUT)
    @@logger.level = Logger::INFO
    @@domain = nil

    def self.__define_accessors
      class_variables.each do |v|
        sym = v.to_s.delete("@").to_sym
        unless self.respond_to? sym
          module_eval <<-EOS, __FILE__, __LINE__
            def self.#{sym}
              value = if defined?(#{sym.to_s.upcase})
                #{sym.to_s.upcase}
              else
                @@#{sym}
              end
              if value.is_a?(Hash)
                value = (self.domain.nil? ? nil : value[self.domain]) || value.values.first
              end
              value
            end

            def self.#{sym}=(obj)
              @@#{sym} = obj
            end
          EOS
        end
      end
    end

    __define_accessors

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------

    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    class Geocoder

      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # nil one with a failed success code.
      def self.geocode(address, options = {})
        if  address.is_a?(String)
          converted_address = ActiveSupport::Inflector.transliterate(address)
        else
          converted_address = address
        end
        do_geocode(converted_address, options)
      end
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # nil one with a failed success code.
      def self.reverse_geocode(latlng)
        do_reverse_geocode(latlng)
      end

      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout::timeout(Geokit::Geocoders::request_timeout) { return self.do_get(url) } if Geokit::Geocoders::request_timeout
        logger.info "Getting geocode from #{url}"
        return self.do_get(url)
      rescue TimeoutError, Timeout::Error
        raise Geokit::TimeoutError
      rescue Yajl::HttpStream::HttpError
        raise Geokit::InvalidResponseError
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        return nil
      end

      protected

      def self.logger()
        Geokit::Geocoders::logger
      end

      private

      # Wraps the geocoder call around a proxy if necessary.
      def self.do_get(url)
        uri = URI.parse(url)
        result = nil
        Yajl::HttpStream.get(uri, {:check_utf8 => false}) do |data|
          result = data
        end
        result
      end

    end
  end
end
