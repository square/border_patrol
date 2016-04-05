require 'spec_helper'

describe BorderPatrol do
  Support_Folder = Bundler.root + 'spec/support'

  describe '.parse_kml' do
    it 'returns a BorderPatrol::Region containing a BorderPatrol::Polygon for each polygon in the KML file' do
      kml_data = File.read(Support_Folder + 'multi-polygon-test.kml')
      region = BorderPatrol.parse_kml(kml_data)
      expect(region.length).to eq(3)
      region.each { |p| expect(p).to be_a BorderPatrol::Polygon }
    end

    context 'when there is only one polygon' do
      it 'returns a region containing a single polygon' do
        kml_data = File.read(Support_Folder + 'colorado-test.kml')
        region = BorderPatrol.parse_kml(kml_data)
        expect(region.length).to eq(1)
        region.each { |p| expect(p).to be_a BorderPatrol::Polygon }
      end
    end

    context 'xmlns attributes' do
      it 'should not care about the xmlns of the <kml> tag' do
        kml_data = File.read(Support_Folder + 'elgin-opengis-ns-test.kml')
        region = BorderPatrol.parse_kml(kml_data)
        expect(region.length).to eq(7)
        region.each { |p| expect(p).to be_a BorderPatrol::Polygon }
      end
    end
  end

  describe '.parse_kml_polygon_data' do
    it 'returns a BorderPatrol::Polygon with the points from the kml data in the correct order' do
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
      expect(polygon).to eq(BorderPatrol::Polygon.new(BorderPatrol::Point.new(-10, 25), BorderPatrol::Point.new(-1, 30), BorderPatrol::Point.new(10, 1), BorderPatrol::Point.new(0, -5)))
    end
  end

  describe '.placemark_name_for_polygon' do
    it 'returns the name of the placemark when Placemark is the parent node' do
      kml_data = File.read(Support_Folder + 'colorado-test.kml')
      doc = Nokogiri::XML(kml_data)
      polygon_node = doc.search('Polygon').first

      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      expect(placemark_name).to eq('Shape 1')
    end

    it 'returns the name of the placemark when MultiGeometry is the parent node' do
      kml_data = File.read(Support_Folder + 'elgin-opengis-ns-test.kml')
      doc = Nokogiri::XML(kml_data)
      polygon_node = doc.search('Polygon').first

      placemark_name = BorderPatrol.placemark_name_for_polygon(polygon_node)
      expect(placemark_name).to eq('Elgin')
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
      expect(placemark_name).to be_nil
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
      expect(placemark_name).to eq('')
    end
  end

  describe BorderPatrol::Point do
    describe '==' do
      it 'is true if both points contain the same values' do
        expect(BorderPatrol::Point.new(1, 2)).to eq(BorderPatrol::Point.new(1, 2))
      end

      it 'is true if one point contains floats and one contains integers' do
        expect(BorderPatrol::Point.new(1, 2.0)).to eq(BorderPatrol::Point.new(1.0, 2))
      end

      it 'is false if the points contain different values' do
        expect(BorderPatrol::Point.new(1, 3)).not_to eq(BorderPatrol::Point.new(1.0, 2))
      end
    end
  end


  describe "KMLs with with holes" do
    before(:each) do
      @outside = [
        BorderPatrol::Point.new(-74.0063, 40.72368),
        BorderPatrol::Point.new(-74.00678, 40.71912),
        BorderPatrol::Point.new(-74.00686, 40.71571),
        BorderPatrol::Point.new(-74.00201, 40.71554),
        BorderPatrol::Point.new(-73.99695, 40.71558),
      ]

      @in_the_polygon = [
        BorderPatrol::Point.new(-74.00193, 40.72299),
        BorderPatrol::Point.new(-74.00188, 40.71951),
        BorderPatrol::Point.new(-73.99669, 40.71942),
      ]

      @in_the_hole = [
        BorderPatrol::Point.new(-73.99618, 40.72338)
      ]
    end

    it 'correctly identifies points inside and outside polygon which has 1 hole' do
      region = BorderPatrol.parse_kml(File.read('spec/support/polygon-with-hole-test1.kml'))
      @outside.each do |p|
        expect(region.contains_point?(p)).to be false
      end
      @in_the_polygon.each do |p|
        expect(region.contains_point?(p)).to be true
      end
      @in_the_hole.each do |p|
        expect(region.contains_point?(p)).to be false
      end
    end

    it 'correctly identifies points inside and outside polygon which has 2 holes' do
      region = BorderPatrol.parse_kml(File.read('spec/support/polygon-with-2-holes.kml'))
      @outside.each do |p|
        expect(region.contains_point?(p)).to be false
      end
      @in_the_polygon.each do |p|
        expect(region.contains_point?(p)).to be true
      end
      @in_the_hole.each do |p|
        expect(region.contains_point?(p)).to be false
      end
    end

    it 'correctly identifies points inside and outside polygon with real-world polygon' do
      region = BorderPatrol.parse_kml(File.read('spec/support/45.kml'))
      in1 = BorderPatrol::Point.new(-73.80001, 40.87513)
      in_hole1 = BorderPatrol::Point.new(-73.79593, 40.87487)
      outside1 = BorderPatrol::Point.new(-73.77881, 40.87393)
      way_out1 = BorderPatrol::Point.new(-73.76242, 40.88194)
      in_another_polygon = BorderPatrol::Point.new(-73.77134, 40.8712)
      expect(region.contains_point?(in1)).to be true
      expect(region.contains_point?(in_hole1)).to be false
      expect(region.contains_point?(outside1)).to be false
      expect(region.contains_point?(way_out1)).to be false
      expect(region.contains_point?(in_another_polygon)).to be true
    end

  end

end
