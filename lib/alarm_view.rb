require 'time_period_view'

class AlarmView < FXScrollWindow
  
  attr_reader :alarm
  
  def initialize(p,alarm)
    super(p, :opts=>LAYOUT_FILL)
    @alarm = alarm
    FXVerticalFrame.new(self, :opts=>LAYOUT_FILL)
    @alarm.each {|time_period| add_time_period(time_period) }
  end
  
  def add_time_period(time_period)
    TimePeriodView.new(contentWindow, time_period)
  end
end