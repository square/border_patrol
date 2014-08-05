#!/usr/bin/env ruby -w
require 'spec/spec_helper'
require 'benchmark'

colorado_region = BorderPatrol.parse_kml(File.read('spec/support/colorado-test.kml'))
multi_polygon_region = BorderPatrol.parse_kml(File.read('spec/support/multi-polygon-test.kml'))
Benchmark.bm(20) do |x|
  x.report('colorado region') do
    10_000.times do |_i|
      multiple = (rand(2) == 1 ? -1 : 1)
      colorado_region.contains_point?(rand * 180 * multiple, rand * 180 * multiple)
    end
  end

  x.report('multi polygon region') do
    10_000.times do |_i|
      multiple = (rand(2) == 1 ? -1 : 1)
      multi_polygon_region.contains_point?(rand * 180 * multiple, rand * 180 * multiple)
    end
  end
end
