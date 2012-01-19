#---
# LX's Alarm
#--
class Alarm
  include Enumerable
  
  attr_accessor :name
  attr_reader :steps

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
  
  def swap(a,b)
    @steps[a],@steps[b] = @steps[b],@steps[a]
  end
  
end
