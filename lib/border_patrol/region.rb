module BorderPatrol
  class Region < Set
    def contains_point?(*point)
      point = case point.length
              when 1
                point.first
              when 2
                BorderPatrol::Point.new(point[0], point[1])
              else
                fail ArgumentError, "#{point} is invalid.  Arguments can either be an object, or a longitude,lattitude pair."
              end
      any? { |polygon| polygon.contains_point?(point) }
    end

    # The below are some general helper methods
    def bounding_boxes
      map(&:bounding_box)
    end

    def bounding_box
      boxes = bounding_boxes
      boxes.flatten!

      BorderPatrol.bounding_box(boxes)
    end

    def central_point
      BorderPatrol.central_point(bounding_box)
    end
  end
end
