require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'testcase'
require 'fox16'
include Fox

require 'time_period_view'

class TC_TimePeriodView < TestCase
  def setup
    super("TC_TimePeriodView")
    tp = TimePeriod.new("Mix Flour", 20)
    @tpview = TimePeriodView.new(mainWindow,tp)
  end
  
  def test_text
    assert @tpview.text
    assert_instance_of(String, @tpview.text)
    assert_equal "00:20 Mix Flour", @tpview.text
  end
  
  def test_change_text
    tp = TimePeriod.new("Mix Flour", 19)
    @tpview.load_time_period(tp)
    assert_equal "00:19 Mix Flour", @tpview.text
  end
end