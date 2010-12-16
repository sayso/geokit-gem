# encoding: utf-8

require 'test/unit'
require 'rubygems'
require 'mocha'
require File.expand_path(File.dirname(__FILE__) + '/../lib/geokit')
require File.expand_path(File.dirname(__FILE__) + '/fake_geo_requests')

class GoogleGeocoderTest < Test::Unit::TestCase

  include FakeGeoRequests

  def setup
    Geokit::Geocoders::google = 'Google'
    @address = 'San Francisco, CA'    
    @full_address = '100 Spear St, San Francisco, CA, 94105-1522, US'   
    @full_address_short_zip = '100 Spear St, San Francisco, CA, 94105, US' 
    
    @google_full_hash = {:street_address=>"100 Spear St", :city=>"San Francisco", :state=>"CA", :zip=>"94105", :country_code=>"US"}
    @google_city_hash = {:city=>"San Francisco", :state=>"CA"}

    @google_full_loc = Geokit::GeoLoc.new(@google_full_hash)
    @google_city_loc = Geokit::GeoLoc.new(@google_city_hash)
  end  

  def test_google_full_address
    response = response = Yajl::Parser.new.parse(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.7921509,-122.394", res.ll # slightly dif from yahoo
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end
  
  def test_google_full_address_with_geo_loc
    response = response = Yajl::Parser.new.parse(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city 
    assert_equal "37.7921509,-122.394", res.ll # slightly dif from yahoo
    assert res.is_us?
    assert_equal "100 Spear St, San Francisco, CA 94105, USA", res.full_address #slightly different from yahoo
    assert_equal "google", res.provider
  end  
  
  def test_google_full_address_accuracy
    response = response = Yajl::Parser.new.parse(GOOGLE_FULL)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    assert_equal 8, res.accuracy
  end

  def test_google_city
    response = response = Yajl::Parser.new.parse(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city
    assert_equal "37.7749295,-122.4194155", res.ll
    assert res.is_us?
    assert_equal "San Francisco, CA, USA", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
  
  def test_google_city_accuracy
    response = response = Yajl::Parser.new.parse(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    assert_equal 4, res.accuracy
  end
  
  def test_google_city_with_geo_loc
    response = response = Yajl::Parser.new.parse(GOOGLE_CITY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc)
    assert_equal "CA", res.state
    assert_equal "San Francisco", res.city
    assert_equal "37.7749295,-122.4194155", res.ll
    assert res.is_us?
    assert_equal "San Francisco, CA, USA", res.full_address
    assert_nil res.street_address
    assert_equal "google", res.provider
  end  
  
  def test_google_suggested_bounds
    response = response = Yajl::Parser.new.parse(GOOGLE_RESULT_WITH_SUGGESTED_BOUNDS)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@full_address_short_zip)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::GoogleGeocoder.geocode(@google_full_loc)
    
    assert_instance_of Geokit::Bounds, res.suggested_bounds
    assert_equal Geokit::Bounds.new(Geokit::LatLng.new(37.7890033,-122.3971476), Geokit::LatLng.new(37.7952985,-122.3908524)), res.suggested_bounds
  end
  
  def test_service_unavailable
    response = nil
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert_raise Geokit::InvalidResponseError do
      Geokit::Geocoders::GoogleGeocoder.geocode(@google_city_loc)
    end
  end 
  
  def test_multiple_results
    #Geokit::Geocoders::GoogleGeocoder.do_geocode('via Sandro Pertini 8, Ossona, MI')
    response = Yajl::Parser.new.parse(GOOGLE_MULTI)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape('via Sandro Pertini 8, Ossona, MI')}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.geocode('via Sandro Pertini 8, Ossona, MI')
    assert_equal "Lombardia", res.state
    assert_equal "Mesero", res.city
    assert_equal "45.4966218,8.852694", res.ll
    assert !res.is_us?
    assert_equal "Via Sandro Pertini, 8, 20010 Mesero Milan, Italy", res.full_address
    assert_equal "Via Sandro Pertini, 8", res.street_address
    assert_equal "google", res.provider

    assert_equal 2, res.all.size
    res = res.all[1]
    assert_equal "Lombardia", res.state
    assert_equal "Mesero", res.city
    assert_equal "45.4966218,8.852694", res.ll
    assert !res.is_us?
    assert_equal "Via Sandro Pertini, 8, 20010 Mesero Milan, Italy", res.full_address
    assert_equal "Via Sandro Pertini, 8", res.street_address
    assert_equal "google", res.provider
  end

  def test_reverse_geocode
    #Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode("40.4167413, -3.7032498")
    madrid = Geokit::GeoLoc.new
    madrid.lat, madrid.lng = "40.4167413", "-3.7032498"
    response = Yajl::Parser.new.parse(GOOGLE_REVERSE_MADRID)
    url = "http://maps.google.com/maps/geo?ll=#{Geokit::Inflector::url_escape(madrid.ll)}&key=#{Geokit::Geocoders::google}&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).
      returns(response)
    res=Geokit::Geocoders::GoogleGeocoder.do_reverse_geocode(madrid.ll)

    assert_equal madrid.lat.to_s.slice(1..5), res.lat.to_s.slice(1..5)
    assert_equal madrid.lng.to_s.slice(1..5), res.lng.to_s.slice(1..5)
    assert_equal "ES", res.country_code
    assert_equal "google", res.provider

    assert_equal "Madrid", res.city
    assert_equal "Comunidad de Madrid", res.state

    assert_equal "España", res.country
    assert_equal "address", res.precision
    assert_equal true, res.success

    assert_equal "Calle de las Carretas, 3, 28012 Madrid, Spain", res.full_address
    assert_equal "28012", res.zip
    assert_equal "Calle De Las Carretas, 3", res.street_address
  end  
  
  def test_country_code_biasing
    response = Yajl::Parser.new.parse(GOOGLE_COUNTRY_CODE_BIASED_RESULT)
    
    url = "http://maps.google.com/maps/geo?q=Syracusa&gl=it&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('Syracusa', :bias => 'it')
    
    assert_equal 'IT', biased_result.country_code
    assert_equal 'Sicile', biased_result.state
  end
  
  def test_bounds_biasing
    response = Yajl::Parser.new.parse(GOOGLE_BOUNDS_BIASED_RESULT)
    
    url = "http://maps.google.com/maps/geo?q=Winnetka&ll=34.19769320884902,-118.54716002778494&spn=0.2470479999999995,0.29491400000000567&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    
    bounds = Geokit::Bounds.normalize([34.074081, -118.694401], [34.321129, -118.399487])
    biased_result = Geokit::Geocoders::GoogleGeocoder.geocode('Winnetka', :bias => bounds)
    
    assert_equal 'US', biased_result.country_code
    assert_equal 'CA', biased_result.state
  end

  def test_too_many_queries
    response = Yajl::Parser.new.parse(GOOGLE_TOO_MANY)
    url = "http://maps.google.com/maps/geo?q=#{Geokit::Inflector.url_escape(@address)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert_raise Geokit::TooManyQueriesError do
      Geokit::Geocoders::GoogleGeocoder.geocode(@address)
    end
  end
end
