module BorderPatrol
  Point = Struct.new(:x, :y) unless defined?(::BorderPatrol::Point)

  class Point
    alias_method :latitude,   :y
    alias_method :latitude=,  :y=
    alias_method :lat,        :y
    alias_method :lat=,       :y=

    alias_method :longitude,  :x
    alias_method :longitude=, :x=
    alias_method :lng,        :x
    alias_method :lng=,       :x=
    alias_method :lon,        :x
    alias_method :lon=,       :x=

    # Lots of Map APIs want the coordinates in lat-lng order
    def latlng
      [lat, lon]
    end
    alias_method :coords, :latlng

    def inspect
      self.class.inspect_string % latlng
    end

    # IE: #<BorderPatrol::Point(lat, lng) = (-25.363882, 131.044922)>
    def self.inspect_string
      @inspect_string ||= "#<#{name}(lat, lng) = (%p, %p)>"
    end
  end
end
