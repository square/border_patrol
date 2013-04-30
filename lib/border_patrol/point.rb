module BorderPatrol
  class Point < Struct.new(:x, :y)
    alias :latitude   :y
    alias :latitude=  :y=
    alias :lat        :y
    alias :lat=       :y=

    alias :longitude  :x
    alias :longitude= :x=
    alias :lng        :x
    alias :lng=       :x=
    alias :lon        :x
    alias :lon=       :x=

    # Lots of Map APIs want the coordinates in lat-lng order
    def latlng
      [lat, lon]
    end
    alias :coords :latlng

    def inspect
      self.class.inspect_string % self.latlng
    end

    protected
    # IE: #<BorderPatrol::Point(lat, lng) = (-25.363882, 131.044922)>
    def self.inspect_string
      @inspect_string ||= "#<#{self.name}(lat, lng) = (%p, %p)>"
    end
  end
end
