require 'fox16'
include Fox


class TimePeriodView < FXLabel
  def initialize(p,time_period)
    super(p,nil,:opts=>LAYOUT_FILL|FRAME_LINE)
    load_time_period(time_period)
  end
  def load_time_period(time_period)
    self.text = "%s %s" % [time_period.length.to_minute,time_period.name]
  end
end