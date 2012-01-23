require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'step'
require 'alarm'

class TC_Alarm < Test::Unit::TestCase
  def setup
    @alarm = Alarm.new("Cook a Cake")
    @t1=Step.new("Mix Flour", 20*60)
    @t2 = Step.new("Shape the Cake", 10*60)
    @t3 = Step.new("Roaste the Cake", 15*60)
    @alarm << @t1
    @alarm << @t2
    @alarm << @t3
  end
  
  def test_get_and_set_name
    assert_equal "Cook a Cake",@alarm.name
    @alarm.name = "Do an Exercise"
    assert_equal "Do an Exercise", @alarm.name
  end
  
  def test_add_steps_and_get_steps
    t4 = Step.new("A New Step", 10*60)
    @alarm << t4
    assert_equal @t1,@alarm[0]
    assert_equal @t2,@alarm[1]
    assert_equal @t3,@alarm[2]
    assert_equal t4,@alarm[3]
  end
  
  def test_get_duration
    assert_equal @t1.duration + @t2.duration + @t3.duration, @alarm.duration
  end

  def test_countdown
    duration = @alarm.duration
    new_duration = @alarm.countdown
    new_duration = @alarm.countdown
    assert_equal duration-2, @alarm.duration
    assert_equal duration-2, new_duration
  end
end
