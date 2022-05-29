require "./calculator/helpers"

class SunTimes
  class Calculator
    include Helpers

    SECONDS_IN_HOUR   = 3600
    DEGREES_PER_HOUR  = 360.0 / 24.0
    ONE_DAY_TIME_SPAN = Time::Span.new(hours: 24)

    private getter event, datetime, coordinates, zenith

    def initialize(@event : SunTimes::Events,
                   @datetime : Time,
                   @coordinates : SunTimes::Coordinates,
                   @zenith : SunTimes::ZenithType)
    end

    def calculate
      # lngHour
      longitude_hour = coordinates.longitude / DEGREES_PER_HOUR

      # t
      base_time = event.rise? ? 6.0 : 18.0
      approximate_time = datetime.day_of_year + (base_time - longitude_hour) / 24.0

      # M
      mean_sun_anomaly = (0.9856 * approximate_time) - 3.289

      # # L
      sun_true_longitude = mean_sun_anomaly +
                           (1.916 * Math.sin(degrees_to_radians(mean_sun_anomaly))) +
                           (0.020 * Math.sin(2 * degrees_to_radians(mean_sun_anomaly))) +
                           282.634
      sun_true_longitude = coerce_degrees(sun_true_longitude)

      # # RA
      tan_right_ascension = 0.91764 * Math.tan(degrees_to_radians(sun_true_longitude))
      sun_right_ascension = radians_to_degrees(Math.atan(tan_right_ascension))
      sun_right_ascension = coerce_degrees(sun_right_ascension)

      # right ascension value needs to be in the same quadrant as L
      sun_true_longitude_quadrant = (sun_true_longitude / 90.0).floor * 90.0
      sun_right_ascension_quadrant = (sun_right_ascension / 90.0).floor * 90.0
      sun_right_ascension += (sun_true_longitude_quadrant - sun_right_ascension_quadrant)

      # RA = RA / 15
      sun_right_ascension_hours = sun_right_ascension / DEGREES_PER_HOUR

      sin_declination = 0.39782 * Math.sin(degrees_to_radians(sun_true_longitude))
      cos_declination = Math.cos(Math.asin(sin_declination))

      cos_local_hour_angle =
        (Math.cos(degrees_to_radians(zenith)) - (sin_declination * Math.sin(degrees_to_radians(coordinates.latitude)))) /
          (cos_declination * Math.cos(degrees_to_radians(coordinates.latitude)))

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

      # # H = H / 15
      suns_local_hour_hours = suns_local_hour / DEGREES_PER_HOUR

      # # T = H + RA - (0.06571 * t) - 6.622
      local_mean_time = suns_local_hour_hours + sun_right_ascension_hours - (0.06571 * approximate_time) - 6.622

      # # UT = T - lngHour
      gmt_hours = coerce_gmt_hours(local_mean_time - longitude_hour)
      offset_hours = datetime.offset / SECONDS_IN_HOUR

      return calculate_with_other_day(next_day_in_utc(datetime)) if gmt_hours + offset_hours < 0
      return calculate_with_other_day(previous_day_in_utc(datetime)) if gmt_hours + offset_hours > 24

      hour = gmt_hours.floor
      hour_remainder = (gmt_hours.to_f - hour.to_f) * 60.0
      minute = hour_remainder.floor
      seconds = (hour_remainder - minute) * 60.0

      result = Time.utc(datetime.year, datetime.month, datetime.day, hour.to_i, minute.to_i, seconds.to_i)

      result
    end

    private def calculate_with_other_day(datetime)
      return self.class.new(event, datetime, coordinates, zenith).calculate
    end
  end
end
