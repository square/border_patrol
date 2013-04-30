require 'set'
require 'forwardable'
require 'nokogiri'
require 'border_patrol/version'
require 'border_patrol/point'
require 'border_patrol/polygon'
require 'border_patrol/region'

module BorderPatrol
  class InsufficientPointsToActuallyFormAPolygonError < ArgumentError; end

  def self.parse_kml(string)
    doc = Nokogiri::XML(string)

    polygons = doc.search('Polygon').map do |polygon_kml|
      placemark_name = placemark_name_for_polygon(polygon_kml)
      parse_kml_polygon_data(polygon_kml.to_s,placemark_name)
    end
    BorderPatrol::Region.new(polygons)
  end

  private
  def self.parse_kml_polygon_data(string,name = nil)
    doc = Nokogiri::XML(string)
    coordinates = doc.xpath("//coordinates").text.strip.split(/\s+/)
    points = coordinates.map do |coord|
      x, y, z = coord.strip.split(',')
      BorderPatrol::Point.new(x.to_f, y.to_f)
    end
    BorderPatrol::Polygon.new(points).with_placemark_name(name)
  end
  
  def self.placemark_name_for_polygon(p)
    # A polygon can be contained by a MultiGeometry or Placemark
    parent = p.parent
    parent = parent.parent if parent.name == "MultiGeometry"
    
    return nil unless parent.name == "Placemark"
    
    parent.search("name").text
  end
end
