require 'fox16'
include Fox


class WelcomeView < FXPacker
  def initialize(p, opts)
    super(p,:opts => opts)
    label = FXLabel.new(self,"LX's alarm",:opts => LAYOUT_FILL)
    new_font = FXFont.new(app,"Arial",14)
    label.font = new_font
  end
end
