require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'time_period'

class TC_TimePeriod < Test::Unit::TestCase
  def setup
    @time_period = TimePeriod.new("Mix Flour",20)
  end
  def test_create
    assert_equal "Mix Flour", @time_period.name
    assert_equal 20, @time_period.length
  end
end
