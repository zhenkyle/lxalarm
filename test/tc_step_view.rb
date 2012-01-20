require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'testcase'
require 'fox16'
include Fox

require 'step_view'

class TC_StepdView < TestCase
  def setup
    super("TC_StepView")
    tp = Step.new("Mix Flour", 20*60)
    @step_view = StepView.new(mainWindow,tp)
  end
  
  def test_text
    assert @step_view.text
    assert_instance_of(String, @step_view.text)
    assert_equal "00:20:00 Mix Flour", @step_view.text
  end
  
  def test_change_text
    tp = Step.new("Mix Flour", 19*60)
    @step_view.load_step(tp)
    assert_equal "00:19:00 Mix Flour", @step_view.text
  end
end
