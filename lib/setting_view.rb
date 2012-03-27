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
      @alarm.dirty = true
	end

    FXHorizontalSeparator.new(self, LAYOUT_FILL_X|SEPARATOR_GROOVE)
	
    add_terminating_buttons
   
    FXLabel.new(self,"Steps:")
    
    @splitter = FXSplitter.new(self,
      :opts => SPLITTER_HORIZONTAL|LAYOUT_FILL)

    @setting_step_list_view = FXList.new(@splitter, :opts => LAYOUT_FILL|LIST_SINGLESELECT, :width => 100)
    @setting_step_list_view.connect(SEL_SELECTED) do |sender,selector,data|
      i = data
      sender.setCurrentItem(i)
      @name_text.text = @alarm[i].name
      @duration_text.text = @alarm[i].duration.to_s
    end

    p = FXMatrix.new(@splitter, 2, :opts => MATRIX_BY_COLUMNS|LAYOUT_FILL)
    FXLabel.new(p, "Name: ")

    @name_text = FXTextField.new(p, 25)
    @name_text.connect(SEL_COMMAND) do |sender,selector,data|
      i = @setting_step_list_view.currentItem
      @alarm[i].name = sender.text
      @setting_step_list_view.setItem(i,sender.text)
      @alarm.dirty = true
    end
    

    FXLabel.new(p, "Duration: ")
    @duration_text = FXTextField.new(p, 25)
    @duration_text.connect(SEL_VERIFY) do |sender, sel, tentative|
      if tentative =~ /^[0-9]*$/
        false
      else
        true
      end
    end
    @duration_text.connect(SEL_COMMAND) do |sender,selector,data|
      i = @setting_step_list_view.currentItem
      @alarm[i].duration = sender.text.to_i
      @alarm.dirty = true
    end
    
    # Do with steps
    alarm.each do |step|
       @setting_step_list_view.appendItem(step.name)
    end
    @setting_step_list_view.selectItem(0,true)
  end
  

  
  def add_terminating_buttons
    buttons = FXHorizontalFrame.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_BOTTOM)

    add_button = FXButton.new(buttons, "+", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
    add_button.connect(SEL_COMMAND) do |sender,selector,data|
      step = Step.new("Step " + (@alarm.count + 1).to_s, 60)
      i = @setting_step_list_view.currentItem
      if i == @setting_step_list_view.numItems - 1
        @setting_step_list_view.appendItem(step.name)
        @alarm << step
      else
        @setting_step_list_view.insertItem(i+1, step.name)
        @alarm.insert(i+1, step)
      end
      @setting_step_list_view.selectItem(i+1, true)
    end

    remove_button = FXButton.new(buttons, "-", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
    remove_button.connect(SEL_COMMAND) do |sender,selector,data|
      if @alarm.step_count > 1
        i = @setting_step_list_view.currentItem
        @alarm.delete_at(i)
        @setting_step_list_view.removeItem(i)
        @setting_step_list_view.selectItem(i-1,true)
      end
    end
    
    up_button = FXButton.new(buttons, "^", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
    up_button.connect(SEL_COMMAND) do |sender,selector,data|
      i = @setting_step_list_view.currentItem
      if i > 0
        # move @setting_step_list_view items
        @setting_step_list_view.moveItem(i-1,i)
        # move @alarm items
        @alarm.swap_step(i,i-1)
      end
    end

    down_button = FXButton.new(buttons, "V", :opts => BUTTON_NORMAL|LAYOUT_LEFT)
    down_button.connect(SEL_COMMAND) do |sender,selector,data|
      i = @setting_step_list_view.currentItem
      if i < @setting_step_list_view.numItems - 1
        # move @setting_step_list_view items
        @setting_step_list_view.moveItem(i+1,i)
        # move @alarm items
        @alarm.swap_step(i,i+1)
      end
    end


  end
end