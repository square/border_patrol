module BorderPatrol
  class Point < Struct.new(:x, :y)
    alias :lat  :y
    alias :lat= :y=
    alias :lng  :x
    alias :lng= :x=

    alias :latitude   :y
    alias :latitude=  :y=
    alias :longitude  :x
    alias :longitude= :x=
  end
end
