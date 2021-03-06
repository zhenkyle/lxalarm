#---
# LX's Alarm
#--
class Alarm
  include Enumerable
  
  attr_accessor :name, :dirty

  def initialize(name)
    @name = name
    @dirty = false
    @steps = []
  end
  
  def <<(step)
    @steps << step
  end
  def [](index)
    @steps[index]
  end
  
  def each(&block)
    @steps.each(&block)
  end
  
  def insert(index, step)
    @steps.insert(index,step)
  end
  
  def delete_at(index)
  	@steps.delete_at(index)
  end

  def step_count()
  	@steps.count
  end

  def swap_step(index1, index2)
    @steps[index1], @steps[index2] = @steps[index2], @steps[index1]
  end
  
  def duration
    duration = 0
    @steps.each {|step| duration +=step.duration}
    duration
  end

  def countdown
    step = @steps.find {|x| x.duration >0 }
    step.countdown if step != nil
    duration
  end
end
