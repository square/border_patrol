require 'forwardable'
module BorderPatrol
  class Polygon
    extend Forwardable
    def initialize(*args)
      args.flatten!
      args.uniq!
      raise InsufficientPointsToActuallyFormAPolygonError unless args.size > 2
      @points = Array.new(args)
    end

    def_delegators :@points, :size, :each, :first, :include?, :[], :index

    def ==(other)
      # Do we have the right number of points?
      return false unless other.size == size

      # Are the points in the right order?
      first, second = first(2)
      index = other.index(first)
      return false unless index
      direction = (other[index-1] == second) ? -1 : 1
      # Check if the two polygons have the same edges and the same points
      # i.e. [point1, point2, point3] is the same as [point2, point3, point1] is the same as [point3, point2, point1]
      each do |i|
        return false unless i == other[index]
        index = index + direction
        index = 0 if index == size
      end
      true
    end

    # Quick and dirty hash function
    def hash
      @points.inject(0) { |sum, point| sum += point.x + point.y }
    end

    def contains_point?(point)
      if cross_intl_date_line?
        @points.each{|p| p.rechart!}
        point.rechart!
      end

      return false unless inside_bounding_box?(point)
      c = false
      i = -1
      j = self.size - 1
      while (i += 1) < self.size
        if ((self[i].y <= point.y && point.y < self[j].y) ||
          (self[j].y <= point.y && point.y < self[i].y))
          if (point.x < (self[j].x - self[i].x) * (point.y - self[i].y) /
            (self[j].y - self[i].y) + self[i].x)
            c = !c
          end
        end
        j = i
      end
      return c
    end

    def cross_intl_date_line?
      i = -1
      j = self.size - 1
      while (i += 1) < self.size
        if (self[i].x - self[j].x).abs > 180
          return true
        end
        j = i
      end
      return false
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
      max_x, min_x, max_y, min_y = -Float::MAX, Float::MAX, -Float::MAX, Float::MAX
      each do |point|
        max_y = point.y if point.y > max_y
        min_y = point.y if point.y < min_y
        max_x = point.x if point.x > max_x
        min_x = point.x if point.x < min_x
      end
      [Point.new(min_x, max_y), Point.new(max_x, min_y)]
    end
  end
end
