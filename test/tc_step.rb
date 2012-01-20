require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'step'

class TC_Step < Test::Unit::TestCase
  def setup
    @step = Step.new("Mix Flour",20*60)
  end
  def test_get_name_and_duration_properties
    assert_equal "Mix Flour", @step.name
    assert_equal 20*60, @step.duration
  end
  def test_set_name_and_duration_properties
    @step.name = "Changed"
    @step.duration = 10*60
    assert_equal "Changed", @step.name
    assert_equal 10*60, @step.duration
  end
end
