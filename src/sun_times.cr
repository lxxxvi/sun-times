require "./sun_times/calculator"

class SunTimes
  VERSION        = "0.1.0"
  DEFAULT_ZENITH = 90.83333

  alias TimeOrNeverType = Time | Nil
  alias ZenithType = Float64

  enum Events
    Rise
    Set

    def rise?
      self == Events::Rise
    end
  end

  struct Coordinates
    getter latitude, longitude

    def initialize(@latitude : Float64, @longitude : Float64)
    end
  end

  def initialize(@day : Time,
                 @coordinates : Coordinates,
                 @zenith : ZenithType = DEFAULT_ZENITH)
  end

  def self.new(day : Time,
               latitude : Float64,
               longitude : Float64,
               zenith : ZenithType = DEFAULT_ZENITH)
    coordinates = SunTimes::Coordinates.new(latitude: latitude, longitude: longitude)
    new(day, coordinates, zenith)
  end

  def sunrise
    calculate(Events::Rise)
  end

  def sunset
    calculate(Events::Set)
  end

  private def calculate(event : Events)
    SunTimes::Calculator.new(event, @day, @coordinates, @zenith).calculate
  end
end
