require "../../spec_helper"
require "../../fixtures"

include Fixtures
include SunTimes::Calculator::Helpers

describe SunTimes::Calculator::Helpers do
  it "#previous_day_in_utc" do
    previous_day_in_utc(Time.utc(2000, 1, 1)).should eq(Time.utc(1999, 12, 31))
  end

  it "#previous_day_in_utc, local time of Tokyo" do
    date = Time.local(2000, 1, 1, location: time_locations(:tokyo))
    previous_day_in_utc(date).should eq(Time.utc(1999, 12, 30, 15))
  end

  it "#next_day_in_utc" do
    next_day_in_utc(Time.utc(2000, 1, 1)).should eq(Time.utc(2000, 1, 2))
  end

  it "#next_day_in_utc, local time of Tokyo" do
    date = Time.local(2000, 1, 1, location: time_locations(:los_angeles))
    next_day_in_utc(date).should eq(Time.utc(2000, 1, 2, 8))
  end

  it "#degrees_to_radians" do
    degrees_to_radians(0).should eq(0.0)
    degrees_to_radians(180).should eq(Math::PI)
    degrees_to_radians(360).should eq(Math::PI * 2)
  end

  it "#radians_to_degrees" do
    radians_to_degrees(0).should eq(0.0)
    radians_to_degrees(Math::PI).should eq(180)
    radians_to_degrees(Math::PI * 2).should eq(360)
  end

  it "#coerce" do
    coerce(-32, 0, 10).should eq(8)
    coerce(-22, 0, 10).should eq(8)
    coerce(-12, 0, 10).should eq(8)
    coerce(-10, 0, 10).should eq(0)
    coerce(-8, 0, 10).should eq(2)
    coerce(0, 0, 10).should eq(0)
    coerce(8, 0, 10).should eq(8)
    coerce(10, 0, 10).should eq(0)
    coerce(12, 0, 10).should eq(2)
    coerce(22, 0, 10).should eq(2)
    coerce(32, 0, 10).should eq(2)
  end
end
