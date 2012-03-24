require 'step_view'

class AlarmView < FXScrollWindow
  
  attr_reader :alarm
  
  def initialize(p,alarm,opts)
    super(p, :opts=>opts)
    @alarm = alarm
    FXVerticalFrame.new(self, :opts=>LAYOUT_FILL)
    @alarm.each {|step| add_step(step) }
  end
  
  def add_step(step)
    StepView.new(contentWindow, step)
  end
end