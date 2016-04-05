require 'spec_helper'

describe BorderPatrol::Polygon do
  describe '==' do
    it 'is true if polygons are congruent' do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(points)
      poly2 = BorderPatrol::Polygon.new(points.unshift(points.pop))

      expect(poly1).to eq(poly2)
      expect(poly2).to eq(poly1)
      poly3 = BorderPatrol::Polygon.new(points.reverse)
      expect(poly1).to eq(poly3)
      expect(poly3).to eq(poly1)

    end

    it 'cares about order of points' do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(5, 5), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(points)
      points = [BorderPatrol::Point.new(5, 5), BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 4)]
      poly2 = BorderPatrol::Polygon.new(points)

      expect(poly1).not_to eq(poly2)
      expect(poly2).not_to eq(poly1)

    end

    it 'is false if one polygon is a subset' do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(4, 4))
      expect(poly2).not_to eq(poly1)
      expect(poly1).not_to eq(poly2)
    end

    it 'is false if the polygons are not congruent' do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      expect(poly2).not_to eq(poly1)
      expect(poly1).not_to eq(poly2)
    end

    it 'is true if polygons and their inner boundaries are congruent' do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 0), BorderPatrol::Point.new(3,3), BorderPatrol::Point.new(0,3))
      poly1.with_inner_boundaries(BorderPatrol::Polygon.new(BorderPatrol::Point.new(1,1), BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(2, 2), BorderPatrol::Point.new(1,2)))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 0), BorderPatrol::Point.new(3,3), BorderPatrol::Point.new(0,3))
      poly2.with_inner_boundaries(BorderPatrol::Polygon.new(BorderPatrol::Point.new(1,1), BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(2, 2), BorderPatrol::Point.new(1,2)))
      expect(poly1).to eq(poly2)
    end

    it 'is false if polygons inner boundaries are not congruent' do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 0), BorderPatrol::Point.new(3,3), BorderPatrol::Point.new(0,3))
      poly1.with_inner_boundaries(BorderPatrol::Polygon.new(BorderPatrol::Point.new(1,1), BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(2, 2), BorderPatrol::Point.new(1,2)))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 0), BorderPatrol::Point.new(3,3), BorderPatrol::Point.new(0,3))
      poly2.with_inner_boundaries(BorderPatrol::Polygon.new(BorderPatrol::Point.new(1.1,1.1), BorderPatrol::Point.new(2.1, 1.1), BorderPatrol::Point.new(2.1, 2.1), BorderPatrol::Point.new(1.1,2.1)))
      expect(poly1).not_to eq(poly2)
    end
  end

  describe '#initialize' do
    it 'stores a list of points' do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      polygon = BorderPatrol::Polygon.new(points)
      points.each do |point|
        expect(polygon).to include point
      end
    end

    it 'can be instantiated with a arbitrary argument list' do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(* points)
      poly2 = BorderPatrol::Polygon.new(points)
      expect(poly1).to eq(poly2)
    end

    it 'raises if less than 3 points are given' do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(2, 3)]
      expect { BorderPatrol::Polygon.new(points) }.to raise_exception(BorderPatrol::InsufficientPointsToActuallyFormAPolygonError)
      points = [BorderPatrol::Point.new(1, 2)]
      expect { BorderPatrol::Polygon.new(points) }.to raise_exception(BorderPatrol::InsufficientPointsToActuallyFormAPolygonError)
      points = []
      expect { BorderPatrol::Polygon.new(points) }.to raise_exception(BorderPatrol::InsufficientPointsToActuallyFormAPolygonError)
    end

    it "doesn't store duplicated points" do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      duplicate_point = [BorderPatrol::Point.new(1, 2)]
      polygon = BorderPatrol::Polygon.new(points + duplicate_point)
      expect(polygon.size).to eq(3)
      points.each do |point|
        expect(polygon).to include point
      end
    end
  end

  describe '#bounding_box' do
    it 'returns the (max top, max left), (max bottom, max right) as points' do
      points = [BorderPatrol::Point.new(-1, 3), BorderPatrol::Point.new(4, -3), BorderPatrol::Point.new(10, 4), BorderPatrol::Point.new(0, 12)]
      polygon = BorderPatrol::Polygon.new(points)
      expect(polygon.bounding_box).to eq([BorderPatrol::Point.new(-1, 12), BorderPatrol::Point.new(10, -3)])
    end
  end

  describe '#contains_point?' do
    context 'when there is no inner boundary' do
      before do
        points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
        @polygon = BorderPatrol::Polygon.new(points)
      end

      it 'is true if the point is in the polygon' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0.5, 0.5))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0, 5))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-1, 3))).to be true
      end

      it 'does not include points on the lines with slopes between vertices' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(5.0, 5.0))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(4.999999, 4.9999999))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0, 0))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0.000001, 0.000001))).to be true
      end

      it 'includes points at the vertices' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-10, 0))).to be true
      end

      it 'is false if the point is outside of the polygon' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(9, 5))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-5, 8))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-10, -1))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-20, -20))).to be false
      end
    end

    context 'when there is an inner boundary' do
      before do
        @polygon = BorderPatrol::Polygon.new(BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 0), BorderPatrol::Point.new(3,3), BorderPatrol::Point.new(0,3))
        @polygon.with_inner_boundaries(BorderPatrol::Polygon.new(BorderPatrol::Point.new(1,1), BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(2, 2), BorderPatrol::Point.new(1,2)))
      end

      it 'is true if the point is in the polygon but not in the inner boundary' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0.5, 1.5))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(0.5, 0.5))).to be true
        expect(@polygon.contains_point?(BorderPatrol::Point.new(1.5, 0.5))).to be true
      end

      it 'is false if the point is outside the polygon' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(4, 0.5))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(2.5, 4))).to be false
        expect(@polygon.contains_point?(BorderPatrol::Point.new(-1, 1.5))).to be false
      end

      it 'is false if the point is inside the inner boundary' do
        expect(@polygon.contains_point?(BorderPatrol::Point.new(1.5, 1.5))).to be false
      end

    end
  end

  describe '#inside_bounding_box?' do
    before do
      points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
      @polygon = BorderPatrol::Polygon.new(points)
    end

    it 'is false if it is outside the bounding box' do
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(-10, -1))).to be false
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(-20, -20))).to be false
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(1, 20))).to be false
    end

    it 'returns true if it is inside the bounding box' do
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(9, 5))).to be true
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(-5, 8))).to be true
      expect(@polygon.inside_bounding_box?(BorderPatrol::Point.new(1, 1))).to be true
    end

  end

  describe '#with_placemark_name' do
    before(:each) do
      points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
      @polygon = BorderPatrol::Polygon.new(points)
    end

    it 'adds a placemark name to a polygon' do
      expect(@polygon.placemark_name).to be_nil

      @polygon.with_placemark_name('Twin Peaks, San Francisco')
      expect(@polygon.placemark_name).to eq('Twin Peaks, San Francisco')
    end

    it 'returns the Polygon object' do
      expect(@polygon.with_placemark_name('Silverlake, Los Angeles')).to equal @polygon
    end

    it 'only allows the placemark name to be set once' do
      expect(@polygon.placemark_name).to be_nil

      @polygon.with_placemark_name('Santa Clara, California')
      expect(@polygon.placemark_name).to eq('Santa Clara, California')

      @polygon.with_placemark_name('Santa Cruz, California')
      expect(@polygon.placemark_name).to eq('Santa Clara, California')
    end
  end
end
