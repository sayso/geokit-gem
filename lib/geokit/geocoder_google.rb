require File.expand_path(File.dirname(__FILE__) + '/geocoders')

module Geokit
  module Geocoders
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
        url = "http://maps.google.com/maps/geo?ll=#{Geokit::Inflector.url_escape(latlng.ll)}&key=#{Geokit::Geocoders::google}&oe=utf-8"
        res = call_geocoder_service(url)
        return GeoLoc.new if res.nil?
        toGeoLoc(res)        
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
      #
      
      GOOGLE_STATUS_CODES = {
        200 => "G_GEO_SUCCESS",
        # InvalidStatusCodeError
        400 => "G_GEO_BAD_REQUEST",
        500 => "G_GEO_SERVER_ERROR",
        601 => "G_GEO_MISSING_QUERY",
        # UnableToGeocodeError
        602 => "G_GEO_UNKNOWN_ADDRESS",
        603 => "G_GEO_UNAVAILABLE_ADDRESS",
        604 => "G_GEO_UNKNOWN_DIRECTIONS",
        # BadKey
        610 => "G_GEO_BAD_KEY",
        # TooManyQueriesError
        620 => "G_GEO_TOO_MANY_QUERIES",
      }
      

      def self.do_geocode(address, options = {})
        bias_str = options[:bias] ? construct_bias_string_from_options(options[:bias]) : ''
        lang_str = options[:lang].to_s.empty? ? '' :  "&hl=#{options[:lang]}"
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        return nil if address_str.to_s.strip.empty?
        url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(address_str)}#{bias_str}#{lang_str}&key=#{Geokit::Geocoders::google}&oe=utf-8"
        res = call_geocoder_service(url)
        raise Geokit::InvalidResponseError if res.nil?
        toGeoLoc(res)        
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
        response_code = res["Status"]["code"]
        if response_code == 200
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
        else
          if [602, 603, 604].include?(response_code)
            # G_GEO_UNKNOWN_ADDRESS, G_GEO_UNAVAILABLE_ADDRESS, G_GEO_UNKNOWN_DIRECTIONS
            return nil
          elsif [400, 500, 601].include?(response_code)
            # G_GEO_BAD_REQUEST, G_GEO_SERVER_ERROR, G_GEO_MISSING_QUERY, G_GEO_BAD_KEY
            raise Geokit::InvalidStatusCodeError.new(GOOGLE_STATUS_CODES[response_code])
          elsif response_code == 620
            # G_GEO_TOO_MANY_QUERIES
            raise Geokit::TooManyQueriesError.new(GOOGLE_STATUS_CODES[response_code])
          elsif response_code == 610
            # G_GEO_BAD_KEY
            raise Geokit::BadKeyError.new(GOOGLE_STATUS_CODES[response_code])
          else
            raise Geokit::GeokitError
          end
        end
      #rescue => e
        logger.error "Caught an error during Google geocoding call: #{e.inspect}"
        return GeoLoc.new
      end  

      # extracts a single geoloc from a //placemark element in the google results xml
      def self.extract_placemark(placemark)
        res = GeoLoc.new
        res.provider = 'google'

        coordinates = placemark["Point"]['coordinates']
        res.lat = coordinates[1]
        res.lng = coordinates[0]

        address_details = placemark['AddressDetails'] 
        if country = address_details['Country']
          res.country_code = country['CountryNameCode']
          res.country = country['CountryName']
          if area = country['AdministrativeArea']
            res.state = area['AdministrativeAreaName']
            if subarea = area['SubAdministrativeArea'] 
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
        
        res.accuracy = address_details ? address_details['Accuracy'].to_i : 0
        res.precision = %w{unknown country state state city zip zip+4 street address building}[res.accuracy]
 
        # google returns a set of suggested boundaries for the geocoded result
        extended_data = placemark['ExtendedData']
        if extended_data && (suggested_bounds = extended_data['LatLonBox']) 
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
