require 'test/unit'
require 'rubygems'
require 'mocha'
require File.expand_path(File.dirname(__FILE__) + '/../lib/geokit')

class GoogleReverseGeocoderTest < Test::Unit::TestCase 
  
  # http://maps.google.com/maps/geo?&oe=utf-8&ll=51.4578329,7.0166848&key=asdad 
  GOOGLE_REVERSE_FULL=<<-EOF.strip  
{
  "name": "51.457833,7.016685",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "Porscheplatz 1, 45127 Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "Locality" : {
               "DependentLocality" : {
                  "DependentLocalityName" : "Stadtkern",
                  "PostalCode" : {
                     "PostalCodeNumber" : "45127"
                  },
                  "Thoroughfare" : {
                     "ThoroughfareName" : "Porscheplatz 1"
                  }
               },
               "LocalityName" : "Essen"
            },
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.4609805,
        "south": 51.4546853,
        "east": 7.0198324,
        "west": 7.0135372
      }
    },
    "Point": {
      "coordinates": [ 7.0166827, 51.4578376, 0 ]
    }
  }, {
    "id": "p2",
    "address": "Stadtkern, 45127 Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 4,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "Locality" : {
               "DependentLocality" : {
                  "DependentLocalityName" : "Stadtkern"
               },
               "LocalityName" : "Essen"
            },
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.4627699,
        "south": 51.4529770,
        "east": 7.0189855,
        "west": 7.0126902
      }
    },
    "Point": {
      "coordinates": [ 7.0151830, 51.4572514, 0 ]
    }
  }, {
    "id": "p3",
    "address": "Stadtkern, Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 4,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "Locality" : {
               "DependentLocality" : {
                  "DependentLocalityName" : "Stadtkern"
               },
               "LocalityName" : "Essen"
            },
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.4630710,
        "south": 51.4506320,
        "east": 7.0193200,
        "west": 7.0026170
      }
    },
    "Point": {
      "coordinates": [ 7.0124328, 51.4568201, 0 ]
    }
  }, {
    "id": "p4",
    "address": "45127 Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 5,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Essen",
               "PostalCode" : {
                  "PostalCodeNumber" : "45127"
               }
            },
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.4637808,
        "south": 51.4503125,
        "east": 7.0231080,
        "west": 6.9965454
      }
    },
    "Point": {
      "coordinates": [ 7.0104543, 51.4556194, 0 ]
    }
  }, {
    "id": "p5",
    "address": "Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 4,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Essen"
            },
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.5342070,
        "south": 51.3475730,
        "east": 7.1376530,
        "west": 6.8943470
      }
    },
    "Point": {
      "coordinates": [ 7.0148281, 51.4579352, 0 ]
    }
  }, {
    "id": "p6",
    "address": "Essen, Germany",
    "AddressDetails": {
   "Accuracy" : 3,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen",
         "SubAdministrativeArea" : {
            "SubAdministrativeAreaName" : "Essen"
         }
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 51.5342070,
        "south": 51.3475730,
        "east": 7.1376530,
        "west": 6.8943470
      }
    },
    "Point": {
      "coordinates": [ 7.0461136, 51.4508381, 0 ]
    }
  }, {
    "id": "p7",
    "address": "North Rhine-Westphalia, Germany",
    "AddressDetails": {
   "Accuracy" : 2,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Nordrhein-Westfalen"
      },
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 52.5314170,
        "south": 50.3225720,
        "east": 9.4615950,
        "west": 5.8663566
      }
    },
    "Point": {
      "coordinates": [ 7.6615938, 51.4332367, 0 ]
    }
  }, {
    "id": "p8",
    "address": "Germany",
    "AddressDetails": {
   "Accuracy" : 1,
   "Country" : {
      "CountryName" : "Deutschland",
      "CountryNameCode" : "DE"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 55.0815000,
        "south": 47.2701270,
        "east": 15.0418321,
        "west": 5.8662579
      }
    },
    "Point": {
      "coordinates": [ 10.4515260, 51.1656910, 0 ]
    }
  } ]
}
  EOF
  
  
  def test_google_full_address
    Geokit::Geocoders::google = 'Google'
   
    # #<Geokit::GeoLoc:0x10ec7ec
    #      @city="Essen",
    #      @country_code="DE",
    #      @full_address="Porscheplatz 1, 45127 Essen, Germany",
    #      @lat=51.4578329,
    #      @lng=7.0166848,
    #      @precision="address",
    #      @provider="google",
    #      @state="Nordrhein-Westfalen",
    #      @street_address="Porscheplatz 1",
    #      @success=true,
    #      @zip="45127">
    #     
    response = Yajl::Parser.new.parse(GOOGLE_REVERSE_FULL)
    @latlng = "51.4578329,7.0166848"
    url = "http://maps.google.com/maps/geo?ll=#{Geokit::Inflector.url_escape(@latlng)}&key=Google&oe=utf-8"
    Geokit::Geocoders::GoogleGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(@latlng) 
    assert_equal "Nordrhein-Westfalen", res.state
    assert_equal "Essen", res.city 
    assert_equal "45127", res.zip
    assert_equal "51.4578376,7.0166827", res.ll
    assert res.is_us? == false
    assert_equal "Porscheplatz 1, 45127 Essen, Germany", res.full_address
    assert_equal "google", res.provider
  end
  
end
