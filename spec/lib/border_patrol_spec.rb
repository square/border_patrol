require 'spec_helper'

describe BorderPatrol do
  Support_Folder = Bundler.root + 'spec/support'

  describe ".parse_kml" do
    it "returns a BorderPatrol::Region containing a BorderPatrol::Polygon for each polygon in the KML file" do
      kml_data = File.read(Support_Folder + "multi-polygon-test.kml")
      region = BorderPatrol.parse_kml(kml_data)
      region.length.should == 3
      region.each {|p| p.should be_a BorderPatrol::Polygon}
    end

    context "when there is only one polygon" do
      it "returns a region containing a single polygon" do
        kml_data = File.read(Support_Folder + "colorado-test.kml")
        region = BorderPatrol.parse_kml(kml_data)
        region.length.should == 1
        region.each {|p| p.should be_a BorderPatrol::Polygon}
      end
    end

    context "xmlns attributes" do
      it "should not care about the xmlns of the <kml> tag" do
        kml_data = File.read(Support_Folder + "elgin-opengis-ns-test.kml")
        region = BorderPatrol.parse_kml(kml_data)
        region.length.should == 7
        region.each {|p| p.should be_a BorderPatrol::Polygon}
      end
    end
  end

  describe ".parse_kml_polygon_data" do
    it "returns a BorderPatrol::Polygon with the points from the kml data in the correct order" do
      kml = <<-EOM
        <Polygon>
          <outerBoundaryIs>
           <LinearRing>
             <tessellate>1</tessellate>
             <coordinates>
               -10,25,0.000000
               -1,30,0.000000 10,1,0.000000
               0,-5,000000
               -10,25,0.000000
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      EOM
      polygon = BorderPatrol.parse_kml_polygon_data(kml)
      polygon.should == BorderPatrol::Polygon.new(BorderPatrol::Point.new(-10, 25), BorderPatrol::Point.new(-1, 30), BorderPatrol::Point.new(10, 1), BorderPatrol::Point.new(0, -5))
    end
  end
  
  describe '.placemark_name_for_polygon' do
    it 'returns the name of the placemark when Placemark is the parent node' do
      kml_data = File.read(Support_Folder + "colorado-test.kml")
      doc = Nokogiri::XML(kml_data)
      polygon_node = doc.search('Polygon').first
      
      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      placemark_name.should == "Shape 1"
    end
    
    it 'returns the name of the placemark when MultiGeometry is the parent node' do
      kml_data = File.read(Support_Folder + "elgin-opengis-ns-test.kml")
      doc = Nokogiri::XML(kml_data)
      polygon_node = doc.search('Polygon').first
      
      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      placemark_name.should == "Elgin"
    end
    
    it 'returns nil when there is no Placemark' do
      kml = <<-EOM
      <MultiGeometry>
        <description><![CDATA[]]></description>
        <styleUrl>#style1</styleUrl>
        <Polygon>
          <outerBoundaryIs>
            <LinearRing>
              <tessellate>1</tessellate>
              <coordinates>
                -109.053040,41.002705,0.000000
                -102.046509,41.006847,0.000000
                -102.041016,36.991585,0.000000
                -109.048920,36.997070,0.000000
                -109.053040,41.002705,0.000000
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </MultiGeometry>
      EOM
      
      doc = Nokogiri::XML(kml)
      polygon_node = doc.search('Polygon').first
      
      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      placemark_name.should be_nil
    end
    
    it 'returns a blank string when there is no Placemark name' do
      kml = <<-EOM
      <Placemark>
        <description><![CDATA[]]></description>
        <styleUrl>#style1</styleUrl>
        <Polygon>
          <outerBoundaryIs>
            <LinearRing>
              <tessellate>1</tessellate>
              <coordinates>
                -109.053040,41.002705,0.000000
                -102.046509,41.006847,0.000000
                -102.041016,36.991585,0.000000
                -109.048920,36.997070,0.000000
                -109.053040,41.002705,0.000000
              </coordinates>
            </LinearRing>
          </outerBoundaryIs>
        </Polygon>
      </Placemark>
      EOM
      
      doc = Nokogiri::XML(kml)
      polygon_node = doc.search('Polygon').first
      
      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      placemark_name.should == ""
    end
  end

  describe BorderPatrol::Point do
    describe "==" do
      it "is true if both points contain the same values" do
        BorderPatrol::Point.new(1,2).should == BorderPatrol::Point.new(1,2)
      end

      it "is true if one point contains floats and one contains integers" do
        BorderPatrol::Point.new(1,2.0).should == BorderPatrol::Point.new(1.0,2)
      end

      it "is false if the points contain different values" do
        BorderPatrol::Point.new(1,3).should_not == BorderPatrol::Point.new(1.0,2)
      end
    end
  end
end
