require File.join(File.dirname(__FILE__),"testhelper")
require 'test/unit'
require 'ext_integer'

class TC_ExtFixnum < Test::Unit::TestCase
  def setup
  end
  def test_right
    assert_equal "00:30:00",(30*60).to_second
    assert_equal "01:30:00",(90*60).to_second
    assert_equal "00:20:34",1234.to_second
    assert_equal "03:25:45",12345.to_second
  end
  def test_range
    assert_raise(RuntimeError) {((99*60+59)*60+60).to_second}
    assert_equal "99:59:59",((99*60+59)*60+59).to_second
    assert_raise(RuntimeError) {0.to_second}
    assert_equal "00:00:01",1.to_second
  end
end
