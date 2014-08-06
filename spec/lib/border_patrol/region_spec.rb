require 'spec_helper'

describe BorderPatrol::Region do
  it 'is a Set' do
    expect(BorderPatrol::Region.new).to be_a Set
  end

  it 'stores the polygons provided at initialization' do
    region = BorderPatrol::Region.new([create_polygon, create_polygon(1), create_polygon(2)])
    expect(region.length).to eq(3)
  end

  describe '#contains_point?' do
    subject { BorderPatrol::Region.new(@polygons) }

    it 'raises an argument error if contains_point? takes more than 3 arguments' do
      expect { subject.contains_point? }.to raise_exception ArgumentError
      expect { subject.contains_point?(1, 2, 3) }.to raise_exception ArgumentError
    end

    it 'returns true if any polygon contains the point' do
      point = BorderPatrol::Point.new(1, 2)
      @polygons = [create_polygon, create_polygon(30)]

      expect(subject.contains_point?(point)).to be true
    end

    it 'returns false if no polygons contain the point' do
      point = BorderPatrol::Point.new(-1, -2)
      @polygons = [create_polygon, create_polygon(30)]

      expect(subject.contains_point?(point)).to be false
    end

    it 'transforms (x,y) coordinates passed in into a point' do
      @polygons = [create_polygon, create_polygon(30)]

      expect(subject.contains_point?(1, 2)).to be true
    end
  end

  def create_polygon(start = 0)
    BorderPatrol::Polygon.new(
      BorderPatrol::Point.new(start, start),
      BorderPatrol::Point.new(start + 10, start),
      BorderPatrol::Point.new(start + 10, start + 10),
      BorderPatrol::Point.new(start, start + 10))
  end

end
