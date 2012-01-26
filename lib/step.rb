require 'observer'

class Step
  include Observable

  attr_accessor :name,:duration
  def initialize(name,duration)
    @name = name
    @duration = duration
  end
  
  def countdown
    if @duration > 0
      @duration -= 1
      changed
      notify_observers(self)
    end
    @duration
  end
end
