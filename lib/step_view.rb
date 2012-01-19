require 'fox16'
include Fox


class StepView < FXLabel
  def initialize(p,step)
    super(p,nil,:opts=>LAYOUT_FILL|FRAME_LINE)
    load_step(step)
  end
  def load_step(step)
    self.text = "%s %s" % [step.length.to_minute,step.name]
  end
end