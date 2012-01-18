class Integer
  def to_minute
    raise "Larger than 99:59 Minute" if self > 99 * 60 + 59
    raise "Smaller than 1 Minute" if self < 1
    hour = self / 60
    minute= self % 60
    "%02d:%02d" % [hour,minute]
  end
end
