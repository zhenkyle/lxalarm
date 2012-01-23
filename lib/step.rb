class Step

  attr_accessor :name,:duration
  def initialize(name,duration)
    @name = name
    @duration = duration
  end
  
  def countdown
    @duration -= 1 if @duration > 0
    @duration
  end
end
