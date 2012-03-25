class SettingStepListView < FXList
  def initialize(p, opts)
    super(p, :opts => opts)
  end
end

class SettingStepView < FXVerticalFrame
  def initialize(p, opts)
    super(p, :opts => opts)
    p = FXMatrix.new(self, 2, :opts => MATRIX_BY_COLUMNS|LAYOUT_FILL)
    FXLabel.new(p, "Name: ")

    @name_target = FXDataTarget.new("Sophia")
    name_text = FXTextField.new(p, 25,
      :target => @name_target, :selector => FXDataTarget::ID_VALUE)

    FXLabel.new(p, "Duration: ")
    duration_text = FXTextField.new(p, 25)

    duration_text.connect(SEL_VERIFY) do |sender, sel, tentative|
      if tentative =~ /^[0-9]*$/
        false
      else
        true
      end
    end

  end
end

class SettingView < FXPacker
  
 
  def initialize(p, alarm, opts)
    super(p,:opts => opts)
    
    @alarm = alarm

    alarm_name_area = FXHorizontalFrame.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_TOP)
    
    FXLabel.new(alarm_name_area, "Alarm: ")

    alarm_name_text = FXTextField.new(alarm_name_area, 25)
    alarm_name_text.connect(SEL_COMMAND) do |sender, selector, data|
      @alarm.name = sender.text
	end

	# Because @alarm.name won't be updated elsewhere, this is not needed
    # alarm_name_text.connect(SEL_UPDATE) do |sender, selector, data|
    #   sender.text = @alarm.name
	# end
	
    FXLabel.new(self,"Steps:")
    
    splitter = FXSplitter.new(self,
      :opts => SPLITTER_HORIZONTAL|LAYOUT_FILL)
    
    @setting_step_list_view = SettingStepListView.new(splitter,LAYOUT_FILL)
    
    @switcher = FXSwitcher.new(splitter, :opts => LAYOUT_FILL)
#    @switcher.connect(SEL_UPDATE) do
#      @switcher.current = @setting_step_list_view.currentItem
#    end
    
    @setting_step_list_view.appendItem("aaa")
    SettingStepView.new(@switcher,LAYOUT_FILL)
    
    add_terminating_buttons
  end
  

  
  def add_terminating_buttons
    buttons = FXHorizontalFrame.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_BOTTOM)
    FXButton.new(buttons, "  OK  ",
      :target => self, :selector => FXDialogBox::ID_ACCEPT,
      :opts => BUTTON_NORMAL|LAYOUT_RIGHT)
    FXButton.new(buttons, "Cancel",
      :target => self, :selector => FXDialogBox::ID_CANCEL,
      :opts => BUTTON_NORMAL|LAYOUT_RIGHT)

      FXButton.new(buttons, "+",
        :target => self, :selector => FXDialogBox::ID_ACCEPT,
        :opts => BUTTON_NORMAL|LAYOUT_LEFT)
      FXButton.new(buttons, "-",
        :target => self, :selector => FXDialogBox::ID_CANCEL,
        :opts => BUTTON_NORMAL|LAYOUT_LEFT)
      FXButton.new(buttons, "^",
        :target => self, :selector => FXDialogBox::ID_CANCEL,
        :opts => BUTTON_NORMAL|LAYOUT_LEFT)
      FXButton.new(buttons, "V",
        :target => self, :selector => FXDialogBox::ID_CANCEL,
        :opts => BUTTON_NORMAL|LAYOUT_LEFT)

  end
end