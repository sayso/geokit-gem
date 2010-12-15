# encoding: utf-8


module FakeGeoRequests
  #Fake resonses are not exactyl the same like from google for testing purposes

  GOOGLE_FULL=<<-EOF.strip
{
  "name": "100 spear st, san francisco, ca",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "100 Spear St, San Francisco, CA 94105, USA",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "CA",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "San Francisco",
               "PostalCode" : {
                  "PostalCodeNumber" : "94105"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "100 Spear St"
               }
            },
            "SubAdministrativeAreaName" : "San Francisco"
         }
      },
      "CountryName" : "USA",
      "CountryNameCode" : "US"
   }
},
    "Point": {
      "coordinates": [ -122.3940000, 37.7921509, 0 ]
    }
  } ]
}
  EOF
  
  GOOGLE_RESULT_WITH_SUGGESTED_BOUNDS=<<-EOF.strip
{
  "name": "100 spear st, san francisco, ca",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "100 Spear St, San Francisco, CA 94105, USA",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "CA",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "San Francisco",
               "PostalCode" : {
                  "PostalCodeNumber" : "94105"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "100 Spear St"
               }
            },
            "SubAdministrativeAreaName" : "San Francisco"
         }
      },
      "CountryName" : "USA",
      "CountryNameCode" : "US"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 37.7952985,
        "south": 37.7890033,
        "east": -122.3908524,
        "west": -122.3971476
      }
    },
    "Point": {
      "coordinates": [ -122.3940000, 37.7921509, 0 ]
    }
  } ]
}
  EOF

  GOOGLE_CITY=<<-EOF.strip
{
  "name": "San Francisco",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "San Francisco, CA, USA",
    "AddressDetails": {
   "Accuracy" : 4,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "CA",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "San Francisco"
            },
            "SubAdministrativeAreaName" : "San Francisco"
         }
      },
      "CountryName" : "USA",
      "CountryNameCode" : "US"
   }
},

    "Point": {
      "coordinates": [ -122.4194155, 37.7749295, 0 ]
    }
  } ]
}
  EOF
  
 GOOGLE_MULTI=<<-EOF
{
  "name": "via Sandro Pertini 8, Ossona, MI",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "Via Sandro Pertini, 8, 20010 Mesero Milan, Italy",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Lombardia",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Mesero",
               "PostalCode" : {
                  "PostalCodeNumber" : "20010"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "Via Sandro Pertini, 8"
               }
            },
            "SubAdministrativeAreaName" : "MI"
         }
      },
      "CountryName" : "Italia",
      "CountryNameCode" : "IT"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 45.4997707,
        "south": 45.4934754,
        "east": 8.8558512,
        "west": 8.8495559
      }
    },
    "Point": {
      "coordinates": [ 8.8526940, 45.4966218, 0 ]
    }
  },{
    "id": "p2",
    "address": "Via Sandro Pertini, 8, 20010 Mesero Milan, Italy",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Lombardia",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Mesero",
               "PostalCode" : {
                  "PostalCodeNumber" : "20010"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "Via Sandro Pertini, 8"
               }
            },
            "SubAdministrativeAreaName" : "MI"
         }
      },
      "CountryName" : "Italia",
      "CountryNameCode" : "IT"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 45.4997707,
        "south": 45.4934754,
        "east": 8.8558512,
        "west": 8.8495559
      }
    },
    "Point": {
      "coordinates": [ 8.8526940, 45.4966218, 0 ]
    }
  }  ]
}
  EOF

   GOOGLE_REVERSE_MADRID=<<-EOF
{
  "name": "40.416741,-3.703250",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "Calle de las Carretas, 3, 28012 Madrid, Spain",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Comunidad de Madrid",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Madrid",
               "PostalCode" : {
                  "PostalCodeNumber" : "28012"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "Calle de las Carretas, 3"
               }
            },
            "SubAdministrativeAreaName" : "Madrid"
         }
      },
      "CountryName" : "España",
      "CountryNameCode" : "ES"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 40.4197745,
        "south": 40.4134793,
        "east": -3.7000393,
        "west": -3.7063345
      }
    },
    "Point": {
      "coordinates": [ -3.7031869, 40.4166269, 0 ]
    }
  }, {
    "id": "p2",
    "address": "Calle de las Carretas, 3, 28012 Madrid, Spain",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Comunidad de Madrid",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Madrid",
               "PostalCode" : {
                  "PostalCodeNumber" : "28012"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "Calle de las Carretas, 3"
               }
            },
            "SubAdministrativeAreaName" : "Madrid"
         }
      },
      "CountryName" : "España",
      "CountryNameCode" : "ES"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 40.4197745,
        "south": 40.4134793,
        "east": -3.7000393,
        "west": -3.7063345
      }
    },
    "Point": {
      "coordinates": [ -3.7031869, 40.4166269, 0 ]
    }
  } , {
    "id": "p3",
    "address": "Calle de las Carretas, 3, 28012 Madrid, Spain",
    "AddressDetails": {
   "Accuracy" : 8,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Comunidad de Madrid",
         "SubAdministrativeArea" : {
            "Locality" : {
               "LocalityName" : "Madrid",
               "PostalCode" : {
                  "PostalCodeNumber" : "28012"
               },
               "Thoroughfare" : {
                  "ThoroughfareName" : "Calle de las Carretas, 3"
               }
            },
            "SubAdministrativeAreaName" : "Madrid"
         }
      },
      "CountryName" : "España",
      "CountryNameCode" : "ES"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 40.4197745,
        "south": 40.4134793,
        "east": -3.7000393,
        "west": -3.7063345
      }
    },
    "Point": {
      "coordinates": [ -3.7031869, 40.4166269, 0 ]
    }
  }  ]
}
  EOF
   
  GOOGLE_COUNTRY_CODE_BIASED_RESULT=<<-EOF.strip
{
  "name": "Syracuse",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "Syracuse, Italy",
    "AddressDetails": {
   "Accuracy" : 3,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "Sicile",
         "SubAdministrativeArea" : {
            "SubAdministrativeAreaName" : "SR"
         }
      },
      "CountryName" : "Italie",
      "CountryNameCode" : "IT"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 37.3474070,
        "south": 36.7775664,
        "east": 15.4978552,
        "west": 14.4733800
      }
    },
    "Point": {
      "coordinates": [ 14.9856176, 37.0630218, 0 ]
    }
  } ]
}

  EOF
  
  GOOGLE_BOUNDS_BIASED_RESULT=<<-EOF.strip
{
  "name": "Winnetka,Ca",
  "Status": {
    "code": 200,
    "request": "geocode"
  },
  "Placemark": [ {
    "id": "p1",
    "address": "Winnetka, Los Angeles, CA, USA",
    "AddressDetails": {
   "Accuracy" : 4,
   "Country" : {
      "AdministrativeArea" : {
         "AdministrativeAreaName" : "CA",
         "SubAdministrativeArea" : {
            "Locality" : {
               "DependentLocality" : {
                  "DependentLocalityName" : "Winnetka"
               },
               "LocalityName" : "Los Angeles"
            },
            "SubAdministrativeAreaName" : "Los Angeles"
         }
      },
      "CountryName" : "USA",
      "CountryNameCode" : "US"
   }
},
    "ExtendedData": {
      "LatLonBox": {
        "north": 34.2317822,
        "south": 34.1948738,
        "east": -118.5390952,
        "west": -118.6031248
      }
    },
    "Point": {
      "coordinates": [ -118.5711100, 34.2133300, 0 ]
    }
  } ]
}
  
  EOF

  GOOGLE_TOO_MANY=<<-EOF.strip
{
  "name": "3435345345",
  "Status": {
    "code": 602,
    "request": "geocode"
  }
}
  
  EOF
 
end
