require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'step'

class TC_Step < Test::Unit::TestCase
  def setup
    @step = Step.new("Mix Flour",20)
  end
  def test_create
    assert_equal "Mix Flour", @step.name
    assert_equal 20, @step.length
  end
end
