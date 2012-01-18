require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'ext_integer'

class TC_ExtFixnum < Test::Unit::TestCase
  def setup
  end
  def test_right
    assert_equal "00:30",30.to_minute
    assert_equal "01:30",90.to_minute
  end
  def test_range
    assert_raise(RuntimeError) {(99*60+60).to_minute}
    assert_nothing_raised() {(99*60+59).to_minute}
    assert_raise(RuntimeError) {0.to_minute}
    assert_nothing_raised() {1.to_minute}
  end
end
