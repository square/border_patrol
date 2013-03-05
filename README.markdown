# BorderPatrol

BorderPatrol allows you import a KML file and then check if points are inside or outside the polygons the file defines.

The KML file may have multiple polygons defined, google maps is a good source.

## Examples

An example KML file can be found here:
http://maps.google.com/maps/ms?ie=UTF8&hl=en&msa=0&ll=38.814031,-103.743896&spn=9.600749,16.248779&z=7&msid=110523771099674876521.00049301d20252132a92c&output=kml

To test if a point is in the region you can either pass a class that responds to `x` and `y` (like the provided BorderPatrol::Point class) or just pass a longitude latitude pair.

    region = BorderPatrol.parse_kml(File.read('spec/support/colorado-test.kml'))
    denver = BorderPatrol::Point.new(-105, 39.75)
    region.contains_point?(denver) # true
    region.contains_point?(-105, 39.75) # also true!
    san_francisco = BorderPatrol::Point.new(-122.5, 37.75)
    region.contains_point?(san_francisco) # false
    region.contains_point?(-122.5, 37.75) # also false!

If you want to use your own point class, just define `x` and `y` as methods that correspond to `longitude` and `latitude`.

## Performance
It's definitely not going to beat a specialized system like PostGIS or SOLR, but it also doesn't have to go across the network to get results.
We've been using it successfully in critical paths in production with zero impact.  Here's a benchmark checking 10,000 random points against the sample files included in the specs.

                              user     system      total        real
    colorado region       0.240000   0.010000   0.250000 (  0.249663)
    multi polygon region  0.610000   0.020000   0.630000 (  0.631532)


## Pro Tip

You can make KML files easily on Google Maps by clicking "My Maps", drawing shapes and saving the map.  Just copy the share link and add "&output=kml" to download the file.g

## Dependencies

* Nokogiri

## Known Issues

Polygons across the international date line don't work.

## Acknowledgements

http://jakescruggs.blogspot.com/2009/07/point-inside-polygon-in-ruby.html for evaluating the algorithm.

http://github.com/nofxx/georuby/ for providing the bounding box code.

## Contributing

Fork and patch! Before any changes are merged to master, we need you to sign an
[Individual Contributor
Agreement](https://spreadsheets.google.com/a/squareup.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1)
(Google Form).