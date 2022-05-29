require "./spec_helper"
require "./fixtures"

include Fixtures

describe SunTimes do
  describe "#sunrise" do
    it "returns the sunrise time" do
      sun_times = SunTimes.new(day: days(:march_8th), coordinates: coordinates(:florence))
      sun_times.sunrise.should eq(Time.utc(2010, 3, 8, 5, 39, 53))
    end

    it "returns the sunrise time with timezone" do
      day_with_zone = Time.local(2011, 12, 13, 0, 0, 0, location: time_locations(:los_angeles))
      sun_times = SunTimes.new(day: day_with_zone, coordinates: coordinates(:portland))
      sun_times.sunrise.should eq(Time.utc(2011, 12, 13, 15, 42, 24))
    end

    it "returns :never in midsummer (continuous light)" do
      sun_times = SunTimes.new(day: days(:midsummer), coordinates: coordinates(:north_cape))
      sun_times.sunrise.should eq(:never)
    end

    it "returns :never in midwinter (continuous night)" do
      sun_times = SunTimes.new(day: days(:midwinter), coordinates: coordinates(:north_cape))
      sun_times.sunrise.should eq(:never)
    end
  end

  describe "#sunset" do
    it "returns the sunset time" do
      sun_times = SunTimes.new(day: days(:march_8th), coordinates: coordinates(:florence))
      sun_times.sunset.should eq(Time.utc(2010, 3, 8, 17, 11, 16))
    end

    it "returns the sunset time with timezone" do
      day_with_zone = Time.local(2011, 12, 13, 0, 0, 0, location: time_locations(:los_angeles))
      sun_times = SunTimes.new(day: day_with_zone, coordinates: coordinates(:portland))
      sun_times.sunset.should eq(Time.utc(2011, 12, 14, 0, 27, 33))
    end

    it "returns :never in midsummer (continuous light)" do
      sun_times = SunTimes.new(day: days(:midsummer), coordinates: coordinates(:north_cape))
      sun_times.sunset.should eq(:never)
    end

    it "returns :never in midwinter (continuous night)" do
      sun_times = SunTimes.new(day: days(:midwinter), coordinates: coordinates(:north_cape))
      sun_times.sunset.should eq(:never)
    end
  end
end
