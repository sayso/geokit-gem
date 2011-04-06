require File.expand_path(File.dirname(__FILE__) + '/geocoders_v3')

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
        url = "http://maps.googleapis.com/maps/api/geocode/json?latlang=#{Geokit::Inflector.url_escape(latlng.ll)}&sensor=true"
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

     ACCURACY = {
       'street_address' => 8,
       'route' => 6,
#       'intersection' => '',
       'country' => 1,
       'administrative_area_level_1' => 2,
       'administrative_area_level_2' => 3,
       'administrative_area_level_3' => 3, #supposed value
       'colloquial_area' => '',
       'locality' => 4,
#       'sublocality' => '',
#       'neighborhood' => '',
#       'premise' => '',
#       'subpremise' => '',
       'postal_code' => 5,
       'natural_feature' => 0,
       'airport' => 8,
       'park' => 8,
       'point_of_interest' => 9,
       'post_box' => 9,
       'street_number' => 9,
       'transit_station' => 9,
       'establishment' => 9,
       'floor' => 9,
       'room' => 9
     }
      
     def self.do_geocode(address, options = {})
        bias_str = options[:bias] ? construct_bias_string_from_options(options[:bias]) : ''
        lang_str = options[:lang].to_s.empty? ? '' :  "&language=#{options[:lang]}"
        address_str = address.is_a?(GeoLoc) ? address.to_geocodeable_s : address
        return nil if address_str.to_s.strip.empty?
        url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{Geokit::Inflector.url_escape(address_str)}#{bias_str}#{lang_str}&sensor=true"
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
        response_code = res["status"]
        if response_code == 'OK'
          geoloc = nil
          # Google can return multiple results as //Placemark elements. 
          # iterate through each and extract each placemark as a geoloc
          res['results'].each do |e|
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
          if response_code == 'ZERO_RESULTS'
            #  non-existent address or a latlng in a remote location
            return nil
           elsif response_code ==  'OVER_QUERY_LIMIT'
            raise Geokit::TooManyQueriesError
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

        res.lat = placemark["geometry"]["location"]["lat"]
        res.lng = placemark["geometry"]["location"]["lng"]

        address_details = placemark['address_components']
        address_details.each do |add|
          case add['types'][0]
          when 'country'
            res.country_code = add['short_name']
            res.country = add['long_name']
          when 'administrative_area_level_1'
            res.state = add['long_name']
          when 'administrative_area_level_2'
            res.province = add['long_name']
          when 'locality'
            res.city = add['long_name']
          when 'sublocality'
            res.district = add['long_name']
          when 'route'
            res.street = add['long_name']
          when 'street_number'
            res.street_number = add['long_name']
          when 'postal_code'
            res.zip = add['long_name']
          end
        end
        res.full_address = placemark['formatted_address']
        res.street_address = res.full_address.sub(Regexp.new("^(.*#{res.street})([^,]*)?(.*)$")){|full_addr| "#{$1}#{$2}"} if res.street

        # Translate accuracy into Yahoo-style token address, street, zip, zip+4, city, state, country
        # For Google, 1=low accuracy, 8=high accuracy
        res.accuracy = ACCURACY[placemark['types'][0]] || 0
        res.precision = %w{unknown country state state city zip zip+4 street address building}[res.accuracy]

        # google returns a set of suggested boundaries for the geocoded result
        if (suggested_bounds = placemark['geometry']['viewport'] || placemark['geometry']['bounds'])
          res.suggested_bounds = Bounds.normalize(
                                  [suggested_bounds['southwest']['lat'], suggested_bounds['southwest']['lng']],
                                  [suggested_bounds['northeast']['lat'], suggested_bounds['northeast']['lng']])
        end
      
        res.success = true

        res
      end
    end
  end  
end


