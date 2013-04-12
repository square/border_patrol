module BorderPatrol
  class InsufficientPointsToActuallyFormAPolygonError < ArgumentError; end
  class Point < Struct.new(:x, :y); end

  class Point
    # Redefines the coordinates of the point. In the new coordinate system,
    # points on either side of the International Date Line are close together,
    # but points on either side of the Prime Meridian are far apart. Applying
    # #rechart! twice brings you back to the original coordinates
    def rechart!
      if self.x > 0
        self.x -= 180
      else
        self.x += 180
      end
    end
  end

  def self.parse_kml(string)
    doc = Nokogiri::XML(string)

    polygons = doc.search('Polygon').map do |polygon_kml|
      parse_kml_polygon_data(polygon_kml.to_s)
    end
    BorderPatrol::Region.new(polygons)
  end

  private
  def self.parse_kml_polygon_data(string)
    doc = Nokogiri::XML(string)
    coordinates = doc.xpath("//coordinates").text.strip.split(/\s+/)
    points = coordinates.map do |coord|
      x, y, z = coord.strip.split(',')
      BorderPatrol::Point.new(x.to_f, y.to_f)
    end
    BorderPatrol::Polygon.new(points)
  end
end

require 'set'
require 'nokogiri'
require 'border_patrol/version'
require 'border_patrol/polygon'
require 'border_patrol/region'
