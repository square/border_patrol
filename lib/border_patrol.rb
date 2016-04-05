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
      parse_kml_polygon_data(polygon_kml.to_s, placemark_name)
    end
    BorderPatrol::Region.new(polygons)
  end

  def self.bounding_box(points)
    max_x, min_x, max_y, min_y = -Float::MAX, Float::MAX, -Float::MAX, Float::MAX
    points.each do |point|
      max_y = point.y if point.y > max_y
      min_y = point.y if point.y < min_y
      max_x = point.x if point.x > max_x
      min_x = point.x if point.x < min_x
    end
    [Point.new(min_x, max_y), Point.new(max_x, min_y)]
  end

  def self.central_point(box)
    point1, point2 = box

    x = (point1.x + point2.x) / 2
    y = (point1.y + point2.y) / 2

    Point.new(x, y)
  end

  private

  def self.parse_kml_polygon_data(string, name = nil)
    doc = Nokogiri::XML(string)
    # "A Polygon is defined by an outer boundary and 0 or more inner boundaries."
    outerboundary = doc.xpath('//outerBoundaryIs')
    innerboundaries = doc.xpath('//innerBoundaryIs')
    coordinates = outerboundary.xpath('.//coordinates').text.strip.split(/\s+/)
    points = points_from_coordinates(coordinates)
    if innerboundaries
      inner_boundary_polygons = innerboundaries.map do |i|
        BorderPatrol::Polygon.new(points_from_coordinates(i.xpath('.//coordinates').text.strip.split(/\s+/)))
      end
      BorderPatrol::Polygon.new(points).with_placemark_name(name).with_inner_boundaries(inner_boundary_polygons)
    else
      BorderPatrol::Polygon.new(points).with_placemark_name(name)
    end
  end

  def self.points_from_coordinates c
    c.map do |coord|
      x, y, _ = coord.strip.split(',')
      BorderPatrol::Point.new(x.to_f, y.to_f)
    end
  end

  def self.placemark_name_for_polygon(p)
    # A polygon can be contained by a MultiGeometry or Placemark
    parent = p.parent
    parent = parent.parent if parent.name == 'MultiGeometry'

    return nil unless parent.name == 'Placemark'

    parent.search('name').text
  end
end
