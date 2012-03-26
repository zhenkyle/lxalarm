class SettingStepView < FXVerticalFrame
  attr_reader :step
  def initialize(p, step, step_list_view, opts)
    super(p, :opts => opts)
    @step = step
    @step_list_view = step_list_view
    
    p = FXMatrix.new(self, 2, :opts => MATRIX_BY_COLUMNS|LAYOUT_FILL)
    FXLabel.new(p, "Name: ")

    name_text = FXTextField.new(p, 25)
    name_text.text = @step.name
    name_text.connect(SEL_COMMAND) do |sender,selector,data|
      @step.name = sender.text
      @step_list_view.setItem(@step_list_view.currentItem,sender.text)
    end
    

    FXLabel.new(p, "Duration: ")
    duration_text = FXTextField.new(p, 25)
    duration_text.text = @step.duration.to_s
    duration_text.connect(SEL_VERIFY) do |sender, sel, tentative|
      if tentative =~ /^[0-9]*$/
        false
      else
        true
      end
    end
    duration_text.connect(SEL_COMMAND) do |sender,selector,data|
      @step.duration = sender.text
    end
  end
end

class SettingView < FXPacker
  
 
  def initialize(p, alarm, opts)
    super(p,:opts => opts)
    
    @alarm = alarm

    alarm_name_area = FXHorizontalFrame.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_TOP)
    
    FXLabel.new(alarm_name_area, "Alarm's name: ")

    alarm_name_text = FXTextField.new(alarm_name_area, 25)

  	# Because @alarm.name won't be updated elsewhere, don't need SEL_UPDATE here
    alarm_name_text.text = @alarm.name

    alarm_name_text.connect(SEL_COMMAND) do |sender, selector, data|
      @alarm.name = sender.text
	end

    FXHorizontalSeparator.new(self, LAYOUT_FILL_X|SEPARATOR_GROOVE)
	
    FXLabel.new(self,"Steps:")
    
    splitter = FXSplitter.new(self,
      :opts => SPLITTER_HORIZONTAL|LAYOUT_FILL)
    
    @setting_step_list_view = FXList.new(splitter, :opts => LAYOUT_FILL, :width => 100)
    
    @switcher = FXSwitcher.new(splitter, :opts => LAYOUT_FILL)
    
    @setting_step_list_view.connect(SEL_COMMAND) do |sender,selector,data|
      @switcher.current = sender.currentItem
    end
    
    
    # Do with steps
    alarm.each do |step|
       @setting_step_list_view.appendItem(step.name)
       step_view = SettingStepView.new(@switcher, step, @setting_step_list_view, LAYOUT_FILL)
    end
    
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
      
      up_button = FXButton.new(buttons, "^", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
      up_button.connect(SEL_COMMAND) do |sender,selector,data|
        i = @setting_step_list_view.currentItem
        if i > 0
          item = @setting_step_list_view.getItemText(i)
          @setting_step_list_view.setItemText(i,@setting_step_list_view.getItemText(i-1))
          @setting_step_list_view.setItemText(i-1,item)
          @alarm.swap_step(i,i-1)
        end
      end
        
      down_button = FXButton.new(buttons, "V", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
      down_button.connect(SEL_COMMAND) do |sender,selector,data|
        i = @setting_step_list_view.currentItem
        if i < @setting_step_list_view.numItems - 1
          item = @setting_step_list_view.getItemText(i)
          @setting_step_list_view.setItemText(i,@setting_step_list_view.getItemText(i+1))
          @setting_step_list_view.setItemText(i+1,item)
          @alarm.swap_step(i,i+1)
        end
      end

  end
end