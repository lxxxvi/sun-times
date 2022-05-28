require "./spec_helper"

describe SunTimes do
  describe "#sunrise" do
    it "returns the sunrise time" do
      expected_rise = Time.utc(2010, 3, 8, 5, 39, 53)
      day = Time.utc(2010, 3, 8)
      latitude = 43.779
      longitude = 11.432
      sun_times = SunTimes.new(day: day, latitude: latitude, longitude: longitude)
      sun_times.sunrise.should eq(expected_rise)
    end

    it "returns the sunrise time with timezone" do
      time_location = Time::Location.load("America/Los_Angeles")
      latitude = 45.52
      longitude = -122.681944
      day_with_zone = Time.local(2011, 12, 13, 0, 0, 0, location: time_location)
      sun_times = SunTimes.new(day: day_with_zone, latitude: latitude, longitude: longitude)
      sun_times.sunrise.should eq(Time.utc(2011, 12, 13, 15, 42, 24))
    end

    it "returns nil if sun never rises" do
      midsummer = Time.utc(2010, 6, 21)
      north_cape_latitude = 71.170219
      north_cape_longitude = 25.785556
      sun_times = SunTimes.new(day: midsummer, latitude: north_cape_latitude, longitude: north_cape_longitude)
      sun_times.sunrise.should be_nil
    end
  end

  describe "#sunset" do
    it "returns the sunset time" do
      expected_set = Time.utc(2010, 3, 8, 17, 11, 16)
      day = Time.utc(2010, 3, 8)
      latitude = 43.779
      longitude = 11.432
      sun_times = SunTimes.new(day: day, latitude: latitude, longitude: longitude)
      sun_times.sunset.should eq(expected_set)
    end

    it "returns the sunset time with timezone" do
      time_location = Time::Location.load("America/Los_Angeles")
      latitude = 45.52
      longitude = -122.681944
      day_with_zone = Time.local(2011, 12, 13, 0, 0, 0, location: time_location)
      sun_times = SunTimes.new(day: day_with_zone, latitude: latitude, longitude: longitude)
      sun_times.sunset.should eq(Time.utc(2011, 12, 14, 0, 27, 33))
    end

    it "returns nil if sun never sets" do
      midsummer = Time.utc(2010, 6, 21)
      north_cape_latitude = 71.170219
      north_cape_longitude = 25.785556
      sun_times = SunTimes.new(day: midsummer, latitude: north_cape_latitude, longitude: north_cape_longitude)
      sun_times.sunset.should be_nil
    end
  end
end
