require 'spec_helper'

describe BorderPatrol::Polygon do
  describe "==" do
    it "is true if polygons are congruent" do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(points)
      poly2 = BorderPatrol::Polygon.new(points.unshift(points.pop))

      poly1.should == poly2
      poly2.should == poly1
      poly3 = BorderPatrol::Polygon.new(points.reverse)
      poly1.should == poly3
      poly3.should == poly1

    end

    it "cares about order of points" do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(5, 5), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(points)
      points = [BorderPatrol::Point.new(5, 5), BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(3, 4)]
      poly2 = BorderPatrol::Polygon.new(points)

      poly1.should_not == poly2
      poly2.should_not == poly1

    end

    it "is false if one polygon is a subset" do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0), BorderPatrol::Point.new(4, 4))
      poly2.should_not == poly1
      poly1.should_not == poly2
    end

    it "is false if the polygons are not congruent" do
      poly1 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      poly2 = BorderPatrol::Polygon.new(BorderPatrol::Point.new(2, 1), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0))
      poly2.should_not == poly1
      poly1.should_not == poly2
    end
  end

  describe "#initialize" do
    it "stores a list of points" do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      polygon = BorderPatrol::Polygon.new(points)
      points.each do |point|
        polygon.should include point
      end
    end

    it "can be instantiated with a arbitrary argument list" do
      points = [BorderPatrol::Point.new(1, 2), BorderPatrol::Point.new(3, 4), BorderPatrol::Point.new(0, 0)]
      poly1 = BorderPatrol::Polygon.new(* points)
      poly2 = BorderPatrol::Polygon.new(points)
      poly1.should == poly2
    end

    it "raises if less than 3 points are given" do
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
      polygon.size.should == 3
      points.each do |point|
        polygon.should include point
      end
    end
  end

  describe "#bounding_box" do
    it "returns the (max top, max left), (max bottom, max right) as points" do
      points = [BorderPatrol::Point.new(-1, 3), BorderPatrol::Point.new(4, -3), BorderPatrol::Point.new(10, 4), BorderPatrol::Point.new(0, 12)]
      polygon = BorderPatrol::Polygon.new(points)
      polygon.bounding_box.should == [BorderPatrol::Point.new(-1, 12), BorderPatrol::Point.new(10, -3)]
    end
  end

  describe "#contains_point?" do
    before do
      points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
      @polygon = BorderPatrol::Polygon.new(points)
    end

    it "is true if the point is in the polygon" do
      @polygon.contains_point?(BorderPatrol::Point.new(0.5, 0.5)).should be_true
      @polygon.contains_point?(BorderPatrol::Point.new(0, 5)).should be_true
      @polygon.contains_point?(BorderPatrol::Point.new(-1, 3)).should be_true
    end

    it "does not include points on the lines with slopes between vertices" do
      @polygon.contains_point?(BorderPatrol::Point.new(5.0, 5.0)).should be_false
      @polygon.contains_point?(BorderPatrol::Point.new(4.999999, 4.9999999)).should be_true
      @polygon.contains_point?(BorderPatrol::Point.new(0, 0)).should be_true
      @polygon.contains_point?(BorderPatrol::Point.new(0.000001, 0.000001)).should be_true
    end

    it "includes points at the vertices" do
      @polygon.contains_point?(BorderPatrol::Point.new(-10, 0)).should be_true
    end

    it "is false if the point is outside of the polygon" do
      @polygon.contains_point?(BorderPatrol::Point.new(9, 5)).should be_false
      @polygon.contains_point?(BorderPatrol::Point.new(-5, 8)).should be_false
      @polygon.contains_point?(BorderPatrol::Point.new(-10, -1)).should be_false
      @polygon.contains_point?(BorderPatrol::Point.new(-20, -20)).should be_false
    end

    it "works for polygons crossing the International Date Line" do
      points = [BorderPatrol::Point.new(-170, 0), BorderPatrol::Point.new(170, 0), BorderPatrol::Point.new(170, 10),BorderPatrol::Point.new(-170, 10)]
      polygon = BorderPatrol::Polygon.new(points)
      point = BorderPatrol::Point.new(179, 5)
      polygon.contains_point?(point).should be_true
    end
  end

  describe "#inside_bounding_box?" do
    before do
      points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
      @polygon = BorderPatrol::Polygon.new(points)
    end

    it "is false if it is outside the bounding box" do
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(-10, -1)).should be_false
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(-20, -20)).should be_false
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(1, 20)).should be_false
    end

    it "returns true if it is inside the bounding box" do
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(9, 5)).should be_true
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(-5, 8)).should be_true
      @polygon.inside_bounding_box?(BorderPatrol::Point.new(1, 1)).should be_true
    end

  end

  describe "#cross_intl_date_line?" do
    it "is false for a polygon not crossing the date line" do
      points = [BorderPatrol::Point.new(-10, 0), BorderPatrol::Point.new(10, 0), BorderPatrol::Point.new(0, 10)]
      polygon = BorderPatrol::Polygon.new(points)
      polygon.cross_intl_date_line?.should be_false
    end

    it "is true for a polygon crossing the date line" do
      points = [BorderPatrol::Point.new(-170, 0), BorderPatrol::Point.new(170, 0), BorderPatrol::Point.new(170, 10)]
      polygon = BorderPatrol::Polygon.new(points)
      polygon.cross_intl_date_line?.should be_true
    end
  end
end

