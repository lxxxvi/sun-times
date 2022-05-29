class SunTimes
  class Calculator
    SECONDS_IN_HOUR   = 3600
    DEGREES_PER_HOUR  = 360.0 / 24.0
    ONE_DAY_TIME_SPAN = Time::Span.new(hours: 24)

    private getter event, datetime, coordinates, zenith

    def initialize(@event : SunTimes::Events,
                   @datetime : Time,
                   @coordinates : SunTimes::Coordinates,
                   @zenith : SunTimes::ZenithType)
    end

    # TODO: REMOVE ME
    def my_debug(message)
      puts message if !ENV["DEBUG"]?.nil?
    end

    def calculate
      my_debug "..........."
      my_debug "event: #{event}"
      my_debug "datetime: #{datetime}"

      # lngHour
      longitude_hour = coordinates.longitude / DEGREES_PER_HOUR
      my_debug "longitude_hour: #{longitude_hour}"

      # t
      base_time = event.rise? ? 6.0 : 18.0
      my_debug "base_time: #{base_time}"
      approximate_time = datetime.day_of_year + (base_time - longitude_hour) / 24.0
      my_debug "approximate_time: #{approximate_time}"

      # M
      mean_sun_anomaly = (0.9856 * approximate_time) - 3.289
      my_debug "mean_sun_anomaly: #{mean_sun_anomaly}"

      # # L
      sun_true_longitude = mean_sun_anomaly +
                           (1.916 * Math.sin(degrees_to_radians(mean_sun_anomaly))) +
                           (0.020 * Math.sin(2 * degrees_to_radians(mean_sun_anomaly))) +
                           282.634
      sun_true_longitude = coerce_degrees(sun_true_longitude)
      my_debug "sun_true_longitude: #{sun_true_longitude}"

      # # RA
      tan_right_ascension = 0.91764 * Math.tan(degrees_to_radians(sun_true_longitude))
      sun_right_ascension = radians_to_degrees(Math.atan(tan_right_ascension))
      sun_right_ascension = coerce_degrees(sun_right_ascension)
      my_debug "tan_right_ascension: #{tan_right_ascension}"

      # right ascension value needs to be in the same quadrant as L
      sun_true_longitude_quadrant = (sun_true_longitude / 90.0).floor * 90.0
      sun_right_ascension_quadrant = (sun_right_ascension / 90.0).floor * 90.0
      sun_right_ascension += (sun_true_longitude_quadrant - sun_right_ascension_quadrant)
      my_debug "sun_right_ascension: #{sun_right_ascension}"

      # RA = RA / 15
      sun_right_ascension_hours = sun_right_ascension / DEGREES_PER_HOUR
      my_debug "sun_right_ascension_hours: #{sun_right_ascension_hours}"

      sin_declination = 0.39782 * Math.sin(degrees_to_radians(sun_true_longitude))
      my_debug "sin_declination: #{sin_declination}"
      cos_declination = Math.cos(Math.asin(sin_declination))
      my_debug "cos_declination: #{cos_declination}"

      cos_local_hour_angle =
        (Math.cos(degrees_to_radians(zenith)) - (sin_declination * Math.sin(degrees_to_radians(coordinates.latitude)))) /
          (cos_declination * Math.cos(degrees_to_radians(coordinates.latitude)))
      my_debug "cos_local_hour_angle: #{cos_local_hour_angle}"

      # the sun never rises on this coordinates (on the specified date)
      return :never if cos_local_hour_angle > 1
      # the sun never sets on this coordinates (on the specified date)
      return :never if cos_local_hour_angle < -1

      # # H
      suns_local_hour =
        if event.rise?
          360 - radians_to_degrees(Math.acos(cos_local_hour_angle))
        else
          radians_to_degrees(Math.acos(cos_local_hour_angle))
        end
      my_debug "suns_local_hour: #{suns_local_hour}"

      # # H = H / 15
      suns_local_hour_hours = suns_local_hour / DEGREES_PER_HOUR
      my_debug "suns_local_hour_hours: #{suns_local_hour_hours}"

      # # T = H + RA - (0.06571 * t) - 6.622
      local_mean_time = suns_local_hour_hours + sun_right_ascension_hours - (0.06571 * approximate_time) - 6.622
      my_debug "local_mean_time: #{local_mean_time}"

      # # UT = T - lngHour
      gmt_hours = local_mean_time - longitude_hour
      gmt_hours -= 24.0 if gmt_hours > 24
      gmt_hours += 24.0 if gmt_hours < 0
      my_debug "gmt_hours: #{gmt_hours}"

      my_debug "datetime.offset: #{datetime.offset}"

      offset_hours = datetime.offset / SECONDS_IN_HOUR
      my_debug "offset_hours: #{offset_hours}"

      return calculate_with_other_day(next_day_in_utc) if gmt_hours + offset_hours < 0
      return calculate_with_other_day(previous_day_in_utc) if gmt_hours + offset_hours > 24

      hour = gmt_hours.floor
      hour_remainder = (gmt_hours.to_f - hour.to_f) * 60.0
      minute = hour_remainder.floor
      seconds = (hour_remainder - minute) * 60.0

      result = Time.utc(datetime.year, datetime.month, datetime.day, hour.to_i, minute.to_i, seconds.to_i)
      my_debug "result: #{result}"

      result
    end

    private def calculate_with_other_day(datetime)
      return self.class.new(event, datetime, coordinates, zenith).calculate
    end

    private def previous_day_in_utc
      new_datetime = datetime - ONE_DAY_TIME_SPAN
      new_datetime.in(Time::Location::UTC)
    end

    private def next_day_in_utc
      new_datetime = datetime + ONE_DAY_TIME_SPAN
      new_datetime.in(Time::Location::UTC)
    end

    private def degrees_to_radians(degrees)
      degrees.to_f / 360.0 * 2.0 * Math::PI
    end

    private def radians_to_degrees(radians)
      radians.to_f * 360.0 / (2.0 * Math::PI)
    end

    private def coerce_degrees(degrees)
      return coerce_degrees(degrees + 360) if degrees < 0
      return coerce_degrees(degrees - 360) if degrees >= 360

      degrees
    end
  end
end
