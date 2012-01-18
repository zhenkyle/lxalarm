require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'testcase'
require 'fox16'
include Fox

require 'alarm_view'

class TC_AlarmView < TestCase
  def setup
    super("TC_AlarmView")
    @alarm = Alarm.new("Cook a Cake")
    @alarm << TimePeriod.new("Mix Flour", 20)
    @alarm << TimePeriod.new("Shape the Cake", 10)
    @alarm << TimePeriod.new("Roaste the Cake", 15)
    @alarm_view = AlarmView.new(mainWindow,@alarm)
  end
  
  def test_scrollable
    assert @alarm_view.methods.include?("setPosition")
  end
end