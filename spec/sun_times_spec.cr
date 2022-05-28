require "./spec_helper"

describe SunTimes do
  it "#sunset" do
    expected_set = Time.utc(2010, 3, 8, 17, 11, 16)
    day = Time.utc(2010, 3, 8)
    latitude = 43.779
    longitude = 11.432
    sun_times = SunTimes.new(day: day, latitude: latitude, longitude: longitude)
    sun_times.sunset.should eq(expected_set)
  end
end
