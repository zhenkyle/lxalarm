class Integer
  def to_second
    raise "Larger than 99:59:59 Second" if self > (99 * 60 + 59) * 60 + 59
    raise "Smaller than 0 Minute" if self < 0
    hour = self / 60 / 60
    minute = (self - hour * 60 * 60) /60
    second = self - hour * 60 * 60 - minute * 60
    "%02d:%02d:%02d" % [hour,minute,second]
  end
end
