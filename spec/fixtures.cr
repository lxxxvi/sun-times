module Fixtures
  def days(key)
    {
      march_8th: Time.utc(2010, 3, 8),
      midsummer: Time.utc(2010, 6, 21),
      midwinter: Time.utc(2010, 12, 21),
    }[key]
  end

  def coordinates(key)
    {
      florence:   SunTimes::Coordinates.new(43.779, 11.432),
      portland:   SunTimes::Coordinates.new(45.52, -122.681944),
      north_cape: SunTimes::Coordinates.new(71.170219, 25.785556),
    }[key]
  end

  def time_locations(key)
    {
      los_angeles: Time::Location.load("America/Los_Angeles"),
    }[key]
  end
end
