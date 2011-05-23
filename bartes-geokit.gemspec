# encoding: utf-8

Gem::Specification.new do |s|
  s.name = %q{sayso-geokit}
  s.version = "1.5.0.3.002"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["SaySo"]
  s.date = %q{2010-12-10}
  s.description = %q{Geokit Gem - forked and gemified for sayso}
  s.email = ["sayso@truvolabs.com"]
  s.extra_rdoc_files = ["Manifest.txt", "README.markdown"]
  s.files = ["Manifest.txt", "README.markdown", "Rakefile", 
             "lib/geokit/geocoders.rb", "lib/geokit/geocoders_v3.rb", "lib/geokit.rb", "lib/geokit/mappable.rb", "lib/geokit/inflector.rb", "lib/geokit/geocoder_google.rb", "lib/geokit/geocoder_google_v3.rb",
             "test/fake_geo_requests.rb","test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_geoloc.rb", "test/test_google_geocoder.rb", "test/test_latlng.rb"]
  s.homepage = %q{http://github.com/sayso/geokit-gem}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{none}
  s.test_files = ["test/test_base_geocoder.rb", "test/test_bounds.rb", "test/test_geoloc.rb", 
                  "test/test_google_geocoder.rb", "test/test_google_reverse_geocoder.rb", 
                  "test/test_inflector.rb", "test/test_latlng.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0.7.8"])
      s.add_runtime_dependency(%q<activesupport>)
    else
      s.add_dependency(%q<yajl-ruby>, [">= 0.7.8"])
      s.add_dependency(%q<activesupport>)
    end
  else
    s.add_dependency(%q<yajl-ruby>, [">= 0.7.8"])
    s.add_dependency(%q<activesupport>)
  end
end


