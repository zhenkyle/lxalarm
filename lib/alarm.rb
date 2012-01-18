#---
# LX's Alarm
#--
class Alarm
  include Enumerable
  
  attr_accessor :name
  attr_reader :time_periods

  def initialize(name)
    @name = name
    @time_periods = []
  end
  
  def <<(other)
    @time_periods << other
  end
  def [](other)
    @time_periods[other]
  end
  
  def each(&block)
    @time_periods.each(&block)
  end
  
  def swap(a,b)
    @time_periods[a],@time_periods[b] = @time_periods[b],@time_periods[a]
  end
  
end
