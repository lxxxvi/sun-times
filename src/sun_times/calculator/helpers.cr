class SunTimes
  class Calculator
    module Helpers
      def previous_day_in_utc(datetime)
        new_datetime = datetime - ONE_DAY_TIME_SPAN
        new_datetime.in(Time::Location::UTC)
      end

      def next_day_in_utc(datetime)
        new_datetime = datetime + ONE_DAY_TIME_SPAN
        new_datetime.in(Time::Location::UTC)
      end

      def degrees_to_radians(degrees)
        degrees.to_f * Math::PI / 180
      end

      def radians_to_degrees(radians)
        radians.to_f * 180 / Math::PI
      end

      def coerce_degrees(degrees)
        coerce(degrees, 0, 360)
      end

      def coerce_gmt_hours(gmt_hours)
        coerce(gmt_hours, 0, 24)
      end

      def coerce(value, minimum, maximum)
        return coerce(value + maximum, minimum, maximum) if value < minimum
        return coerce(value - maximum, minimum, maximum) if value >= maximum

        value
      end
    end
  end
end
