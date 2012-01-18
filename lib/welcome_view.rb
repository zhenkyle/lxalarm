require 'fox16'
include Fox


class WelcomeView < FXImageFrame
  def initialize(p,picture_path)
    super(p,nil,:opts=>LAYOUT_FILL|FRAME_LINE)
    load_image(picture_path)
  end

  def load_image(picture_path)
    File.open(picture_path,"rb") do |io|
      self.image = FXJPGImage.new(app,io.read)
    end
    #scale_to_fullsize
  end
  
  def scaled_width(width)
    [width,self.width].min
  end
  
  def scaled_height(height)
    [height,self.height].min
  end
  
  def scale_to_fullsize
    aspect_ratio = image.width.to_f/image.height
    if image.width > image.height
      image.scale(
        scaled_width(image.width),
        scaled_width(image.width)/aspect_ratio,
        1
      )
    else
      image.scale(
        aspect_ratio*scaled_height(image.height),
        scaled_height(image.height),
        1
      )
    end
  end
end