module BorderPatrol
  class Polygon
    attr_reader :placemark_name, :inner_boundaries
    extend Forwardable

    # Note @points is the outer boundary.
    # A polygon may also have 1 or more inner boundaries.  In order to not change the ctor signature,
    # the inner boundaries are not settable at construction.
    def initialize(*args)
      args.flatten!
      args.uniq!
      fail InsufficientPointsToActuallyFormAPolygonError unless args.size > 2
      @inner_boundaries = []
      @points = Array.new(args)
    end

    def_delegators :@points, :size, :each, :first, :include?, :[], :index

    def with_inner_boundaries(polygons)
      @inner_boundaries = [polygons].flatten
      self
    end

    def with_placemark_name(placemark)
      @placemark_name ||= placemark
      self
    end

    def ==(other)
      # Do we have the right number of points?
      return false unless other.size == size

      # Are the points in the right order?
      first, second = first(2)
      index = other.index(first)
      return false unless index
      direction = (other[index - 1] == second ? -1 : 1)
      # Check if the two polygons have the same edges and the same points
      # i.e. [point1, point2, point3] is the same as [point2, point3, point1] is the same as [point3, point2, point1]
      each do |i|
        return false unless i == other[index]
        index += direction
        index = 0 if index == size
      end
      return true if @inner_boundaries.empty?
      @inner_boundaries == other.inner_boundaries
    end

    # Quick and dirty hash function
    def hash
      @points.map { |point| point.x + point.y }.reduce(&:+).to_i
    end

    def contains_point?(point)
      return false unless inside_bounding_box?(point)
      c = false
      i = -1
      j = size - 1
      while (i += 1) < size
        if (self[i].y <= point.y && point.y < self[j].y) ||
           (self[j].y <= point.y && point.y < self[i].y)
          if point.x < (self[j].x - self[i].x) * (point.y - self[i].y) / (self[j].y - self[i].y) + self[i].x
            c = !c
          end
        end
        j = i
      end
      return c if c == false
      # Check if excluded by any of the inner boundaries
      @inner_boundaries.each do |inner_boundary|
        return false if inner_boundary.contains_point?(point)
      end
      c
    end

    def inside_bounding_box?(point)
      bb_point_1, bb_point_2 = bounding_box
      max_x = [bb_point_1.x, bb_point_2.x].max
      max_y = [bb_point_1.y, bb_point_2.y].max
      min_x = [bb_point_1.x, bb_point_2.x].min
      min_y = [bb_point_1.y, bb_point_2.y].min

      !(point.x < min_x || point.x > max_x || point.y < min_y || point.y > max_y)
    end

    def bounding_box
      BorderPatrol.bounding_box(self)
    end

    def central_point
      BorderPatrol.central_point(bounding_box)
    end
  end
end
