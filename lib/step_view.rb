require 'fox16'
include Fox


class StepView < FXLabel
  def initialize(p,step)
    super(p,nil,:opts=>LAYOUT_FILL|FRAME_LINE)
    step.add_observer(self)
    update(step)
  end
  def update(step)
    self.text = "%s %s" % [step.duration.to_second,step.name]
  end
end
