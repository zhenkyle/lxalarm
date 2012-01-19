require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'step'
require 'alarm'

class TC_Alarm < Test::Unit::TestCase
  def setup
    @alarm = Alarm.new("Cook a Cake")
    @t1=Step.new("Mix Flour", 20)
    @t2 = Step.new("Shape the Cake", 10)
    @t3 = Step.new("Roaste the Cake", 15)
    @alarm << @t1
    @alarm << @t2
    @alarm << @t3
  end
  
  def test_play_with_name
    assert_equal "Cook a Cake",@alarm.name
    @alarm.name = "Do an Exercise"
    assert_equal "Do an Exercise", @alarm.name
  end
  
  def test_add_steps
    assert_equal @t1,@alarm[0]
    assert_equal @t2,@alarm[1]
    assert_equal @t3,@alarm[2]
  end
  
  def test_get_all_steps
    assert_equal [@t1,@t2,@t3], @alarm.steps
  end

  def test_adjust_steps
    @alarm.swap(0,1)
    assert_equal [@t2,@t1,@t3], @alarm.steps
    @alarm.swap(1,2)
    assert_equal [@t2,@t3,@t1], @alarm.steps
  end
end
