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
  end
end
