require 'yaml'
require 'timeout'
require 'logger'
require 'erb'
require 'yajl'
require 'uri'
require 'yajl/http_stream'

module Geokit

  class TooManyQueriesError < StandardError; end

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
    
    # Error which is thrown in the event a geocoding error occurs.
    class GeocodeError < StandardError; end

    # -------------------------------------------------------------------------------------------
    # Geocoder Base class -- every geocoder should inherit from this
    # -------------------------------------------------------------------------------------------    
    
    # The Geocoder base class which defines the interface to be used by all
    # other geocoders.
    class Geocoder   

      # Main method which calls the do_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.geocode(address, options = {}) 
        res = do_geocode(address, options)
        return res.nil? ? GeoLoc.new : res
      end  
      # Main method which calls the do_reverse_geocode template method which subclasses
      # are responsible for implementing.  Returns a populated GeoLoc or an
      # empty one with a failed success code.
      def self.reverse_geocode(latlng)
        res = do_reverse_geocode(latlng)
        return res.success? ? res : GeoLoc.new        
      end
      
      # Call the geocoder service using the timeout if configured.
      def self.call_geocoder_service(url)
        Timeout::timeout(Geokit::Geocoders::request_timeout) { return self.do_get(url) } if Geokit::Geocoders::request_timeout        
        return self.do_get(url)
      rescue TimeoutError, Yajl::HttpStream::HttpError
        return nil  
      end

      # Not all geocoders can do reverse geocoding. So, unless the subclass explicitly overrides this method,
      # a call to reverse_geocode will return an empty GeoLoc. If you happen to be using MultiGeocoder,
      # this will cause it to failover to the next geocoder, which will hopefully be one which supports reverse geocoding.
      def self.do_reverse_geocode(latlng)
        return GeoLoc.new
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
        Yajl::HttpStream.get(uri) do |data|
          result = data
        end
        result
      end
      
    end

    # -------------------------------------------------------------------------------------------
    # Address geocoders that also provide reverse geocoding
    # -------------------------------------------------------------------------------------------

    # Google geocoder implementation.  Requires the Geokit::Geocoders::GOOGLE variable to
    # contain a Google API key.  Conforms to the interface set by the Geocoder class.
    class GoogleGeocoder < Geocoder

      private 
      
      # Template method which does the reverse-geocode lookup.
      def self.do_reverse_geocode(latlng) 
        latlng = LatLng.normalize(latlng)
        res = self.call_geocoder_service("http://maps.google.com/maps/geo?ll=#{url_encode(latlng.ll)}&key=#{Geokit::Geocoders::google}&oe=utf-8")
        return GeoLoc.new if res.nil?
        self.toGeoLoc(res)        
      end  

      # Template method which does the geocode lookup.
      #
      # Supports viewport/country code biasing
      #
      # ==== OPTIONS
      # * :bias - This option makes the Google Geocoder return results biased to a particular
      #           country or viewport. Country code biasing is achieved by passing the ccTLD
      #           ('uk' for .co.uk, for example) as a :bias value. For a list of ccTLD's, 
      #           look here: http://en.wikipedia.org/wiki/CcTLD. By default, the geocoder
      #           will be biased to results within the US (ccTLD .com).
      #
      #           If you'd like the Google Geocoder to prefer results within a given viewport,
      #           you can pass a Geokit::Bounds object as the :bias value.
      #
      # ==== EXAMPLES
      # # By default, the geocoder will return Syracuse, NY
      # Geokit::Geocoders::GoogleGeocoder.geocode('Syracuse').country_code # => 'US'
      # # With country code biasing, it returns Syracuse in Sicily, Italy
      # Geokit::Geocoders::GoogleGeocoder.geocode('Syracuse', :bias => :it).country_code # => 'IT'
      #
      # # By default, the geocoder will return Winnetka, IL
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka').state # => 'IL'
      # # When biased to an bounding box around California, it will now return the Winnetka neighbourhood, CA
      # bounds = Geokit::Bounds.normalize([34.074081, -118.694401], [34.321129, -118.399487])
      # Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => bounds).state # => 'CA'
      def self.do_geocode(address, options = {})
        bias_str = options[:bias] ? construct_bias_string_from_options(options[:bias]) : ''
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        res = self.call_geocoder_service("http://maps.google.com/maps/geo?q=#{url_escape(address_str)}&#{bias_str}&key=#{Geokit::Geocoders::google}&oe=utf-8")
        return GeoLoc.new if res.nil?
        return self.toGeoLoc(res)        
      end
      
      def self.construct_bias_string_from_options(bias)
        if bias.is_a?(String) or bias.is_a?(Symbol)
          # country code biasing
          "&gl=#{bias.to_s.downcase}"
        elsif bias.is_a?(Bounds)
          # viewport biasing
          "&ll=#{bias.center.ll}&spn=#{bias.to_span.ll}"
        end
      end
      
      def self.toGeoLoc(res)

        if res["Status"]["Code"] == '200'
          geoloc = nil
          # Google can return multiple results as //Placemark elements. 
          # iterate through each and extract each placemark as a geoloc
          res['Placemark'].each do |e|
            extracted_geoloc = extract_placemark(e) # g is now an instance of GeoLoc
            if geoloc.nil? 
              # first time through, geoloc is still nil, so we make it the geoloc we just extracted
              geoloc = extracted_geoloc 
            else
              # second (and subsequent) iterations, we push additional 
              # geolocs onto "geoloc.all" 
              geoloc.all.push(extracted_geoloc) 
            end  
          end
          return geoloc
        elsif res["Status"]["Code"] == '620'
          raise Geokit::TooManyQueriesError
        else
          logger.info "Google was unable to geocode address: " + res["name"]
          return GeoLoc.new
        end

      rescue Geokit::TooManyQueriesError
        # re-raise because of other rescue
        raise Geokit::TooManyQueriesError, "Google returned a 620 status, too many queries. The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly."
      rescue
        logger.error "Caught an error during Google geocoding call: "+$!
        return GeoLoc.new
      end  

      # extracts a single geoloc from a //placemark element in the google results xml
      def self.extract_placemark(placemark)
        res = GeoLoc.new
        res.provider = 'google'

        #basics
        coordinates = placemark["Point"]['coordinates']
        res.lat = coordinates[1]
        res.lng = coordinates[0]
        if country = placemark['Country']
          res.country_code = country['CountryNameCode']
          res.country = country['CountryName']
          if area = country['AdministrativeArea']
            res.state = area['AdministrativeAreaName']
            if subarea = placemark['AdministrativeArea']['SubAdministrativeArea'] 
              locality = subarea['Locality']
              res.province = subarea['SubAdministrativeAreaName']
            end
            locality ||= area['Locality']
            if locality
              street = locality['Thoroughfare']
              postal_code = locality['PostalCode']
              dependant_locality = locality["DependentLocality"]
              if dependant_locality
                res.district = dependant_locality['DependentLocalityName']
                street ||= dependant_locality['Thoroughfare']
                postal_code ||= dependant_locality['PostalCode']
              end
              res.city = locality['LocalityName']
            end
          end
          street ||= country['Thoroughfare']
          postal_code ||= country['PostalCode']
          res.street_address = street['ThoroughfareName'] if street
          res.zip = postal_code['PostalCodeNumber'] if postal_code
        end
        res.full_address = placemark['address']

        # Translate accuracy into Yahoo-style token address, street, zip, zip+4, city, state, country
        # For Google, 1=low accuracy, 8=high accuracy
        
        res.accuracy = placemark['AddressDetails'] ? address_details['Accuracy'].to_i : 0
        res.precision = %w{unknown country state state city zip zip+4 street address building}[res.accuracy]
        
        # google returns a set of suggested boundaries for the geocoded result
        if suggested_bounds = placemark['ExtendedData']['LatLonBox']  
          res.suggested_bounds = Bounds.normalize(
                                  [suggested_bounds['south'], suggested_bounds['west']], 
                                  [suggested_bounds['north'], suggested_bounds['east']])
        end
        
        res.success = true

        res
      end
    end
  end  
end
