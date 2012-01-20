#---
# LX's Alarm
#--
class Alarm
  include Enumerable
  
  attr_accessor :name

  def initialize(name)
    @name = name
    @steps = []
  end
  
  def <<(step)
    @steps << step
  end
  def [](step)
    @steps[step]
  end
  
  def each(&block)
    @steps.each(&block)
  end
  
  def duration
    duration = 0
    @steps.each {|step| duration +=step.duration}
    duration
  end
end
