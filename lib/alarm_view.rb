require 'step_view'

class AlarmView < FXScrollWindow
  
  attr_reader :alarm
  
  def initialize(p,alarm)
    super(p, :opts=>LAYOUT_FILL)
    @alarm = alarm
    FXVerticalFrame.new(self, :opts=>LAYOUT_FILL)
    @alarm.each {|step| add_step(step) }
  end
  
  def add_step(step)
    StepView.new(contentWindow, step)
  end
end