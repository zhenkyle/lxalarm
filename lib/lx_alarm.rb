require 'fox16'
include Fox

# require basics
require 'ext_integer'
require 'step'
require 'alarm'
require 'yaml'

# require views
require 'step_view'
require 'alarm_view'
require 'welcome_view'


class LXAlarm < FXMainWindow
  
  # How often our timer will fire (in milliseconds)
  TIMER_INTERVAL = 1000
  
  def initialize(app)
    super(app,"LX's Alarm: An Alarm with step settings", :width => 650, :height => 450)
    add_menu_bar
    add_tool_bar
    add_status_bar
   
    @switcher = FXSwitcher.new(self, :opts => LAYOUT_FILL)
    
    #Creating Welcome View
    @welcome_view =WelcomeView.new(@switcher)
    
    # Initialize private variables
    @alarm = nil
    @alarm_dirty = false
    @counting_down = false
    #for test
    #@alarm = YAML.load_file("cook_a_cake.alm")
    #AlarmView.new(@switcher,@alarm)
    #@switcher.setCurrent 1
end
  
  
  def add_menu_bar
    menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    # File Menu
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "File", :popupMenu => file_menu)

    # File Menu -- New
    new_alarm_command = FXMenuCommand.new(file_menu, "New")
    new_alarm_command.connect(SEL_COMMAND) do
      alarm_title =
        FXInputDialog.getString("My Alarm", self, "New Alarm", "Name:")
      if alarm_title
        @alarm = Alarm.new(alarm_title)
      end
    end

    # File Menu -- Open...
    open_cmd = FXMenuCommand.new(file_menu, "Open...")
    open_cmd.connect(SEL_COMMAND) do
      dialog = FXFileDialog.new(self, "Open an Alarm")
      dialog.selectMode = SELECTFILE_EXISTING
      dialog.patternList = ["Alarm Files (*.alm)"]
      if dialog.execute != 0
        open_alarm_file(dialog.filename)
      end
    end

    # File Menu -- Seperator
    FXMenuSeparator.new(file_menu)

    # File Menu -- Save
    save_cmd = FXMenuCommand.new(file_menu, "Save")
    save_cmd.connect(SEL_COMMAND) do
    end
    save_cmd.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = (! @alarm.nil?) && @alarm_dirty
    end

    # File Menu -- Save As ...
    save_as_cmd = FXMenuCommand.new(file_menu, "Save As ...")
    save_as_cmd.connect(SEL_COMMAND) do
    end
    save_as_cmd.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = (! @alarm.nil?) && @alarm_dirty
    end

    # File Menu -- Seperator
    FXMenuSeparator.new(file_menu)

    # File Menu -- Close
    close_cmd = FXMenuCommand.new(file_menu, "Close")
    close_cmd.connect(SEL_COMMAND) do
    end
    close_cmd.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = ! @alarm.nil?
    end

    # File Menu -- Exit
    exit_cmd = FXMenuCommand.new(file_menu, "Exit")
    exit_cmd.connect(SEL_COMMAND) do
      store_alarm_file
      clean_up(self)
      exit
    end

    # Edit Menu
    edit_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Edit", :popupMenu => edit_menu)

    # Edit Menu -- Edit Alarm
    edit_alarm_cmd = FXMenuCommand.new(edit_menu, "Edit Alarm")
    edit_alarm_cmd.connect(SEL_COMMAND) do
    end
    edit_alarm_cmd.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = !@alarm.nil?
    end

    # Edit Menu -- Seperator
    FXMenuSeparator.new(edit_menu)

    # Edit Menu -- Preferences ...
    preferences_cmd = FXMenuCommand.new(edit_menu, "Preferences ...")
    preferences_cmd.connect(SEL_COMMAND) do
    end

    # View Menu
    view_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "View", :popupMenu => view_menu)

    # View Menu -- Toolbar
    view_toolbar_cmd = FXMenuCommand.new(view_menu, "Tool bar")
    view_toolbar_cmd.connect(SEL_COMMAND) do
    end

    # View Menu -- Statusbar
    view_statusbar_cmd = FXMenuCommand.new(view_menu, "Status bar")
    view_statusbar_cmd.connect(SEL_COMMAND) do
    end

    # Control Menu
    control_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Control", :popupMenu => control_menu)

    # Control Menu -- Start
    start_cmd = FXMenuCommand.new(control_menu, "Start")
    start_cmd.connect(SEL_COMMAND) do
      @counting_down = true
      getApp().addTimeout(TIMER_INTERVAL, method(:onTimeout))
    end
    start_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        @counting_down ? sender.disable : sender.enable
      end
    end

    # Control Menu -- Stop
    stop_cmd = FXMenuCommand.new(control_menu, "Stop")
    stop_cmd.connect(SEL_COMMAND, method(:onCmdStopTimer))
    stop_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        @counting_down ? sender.enable : sender.disable
      end
    end

    # Control Menu -- Seperator
    FXMenuSeparator.new(control_menu)

    # Control Menu -- Previous Step
    previous_cmd = FXMenuCommand.new(control_menu, "Previous Step")
    previous_cmd.connect(SEL_COMMAND) do
    end
    previous_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        !@counting_down ? sender.disable : sender.enable
      end
    end

    # Control Menu -- Pause
    pause_cmd = FXMenuCommand.new(control_menu, "Pause")
    pause_cmd.connect(SEL_COMMAND) do
    end
    pause_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        !@counting_down ? sender.disable : sender.enable
      end
    end

    # Control Menu -- Next Step
    next_cmd = FXMenuCommand.new(control_menu, "Next Step")
    next_cmd.connect(SEL_COMMAND) do
    end
    next_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        !@counting_down ? sender.disable : sender.enable
      end
    end


    # Help Menu
    help_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Help", :popupMenu => help_menu)

    # Help Menu -- Help
    help_cmd = FXMenuCommand.new(help_menu, "Help")
    help_cmd.connect(SEL_COMMAND) do
    end

    # Help Menu -- About
    about_cmd = FXMenuCommand.new(help_menu, "About LX's Alarm")
    about_cmd.connect(SEL_COMMAND) do
    end

  end

  def add_tool_bar
    tool_bar_shell = FXToolBarShell.new(self)


    top_dock_site = FXDockSite.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_TOP)
    bottom_dock_site = FXDockSite.new(self,
      :opts => LAYOUT_FILL_X|LAYOUT_SIDE_BOTTOM)

    tool_bar = FXToolBar.new(top_dock_site, tool_bar_shell,
      :opts => PACK_UNIFORM_WIDTH|FRAME_RAISED|LAYOUT_FILL_X)

    FXToolBarGrip.new(tool_bar,
      :target => tool_bar, :selector => FXToolBar::ID_TOOLBARGRIP,
      :opts => TOOLBARGRIP_DOUBLE)

    new_icon = load_icon("new-doc-icon.png")
    open_icon = load_icon("open-alt-icon.png")
    save_icon = load_icon("save-icon.png")
    save_as_icon = load_icon("install-icon.png")
    exit_icon = load_icon("exit-icon.png")
    edit_alarm_icon = load_icon("notebook-icon.png")
    preferences_icon = load_icon("advanced-icon.png")
    start_icon = load_icon("play-icon.png")
    stop_icon = load_icon("stop-alt-icon.png")
    previous_icon = load_icon("rewind-button-icon.png")
    pause_icon = load_icon("pause-icon.png")
    next_icon = load_icon("forward-button-icon.png")
    help_icon = load_icon("help-icon.png")
    about_icon = load_icon("info-icon.png")

    # File Toolbar
    new_button = FXButton.new(tool_bar,
      "\tNew\tCreate new alarm.",
      :icon => new_icon)
    open_button = FXButton.new(tool_bar,
      "\tOpen ...\tOpen an alarm from file.",
      :icon => open_icon)
    save_button = FXButton.new(tool_bar,
      "\tSave\tSave alarm.",
      :icon => save_icon)
    save_button.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = (! @alarm.nil?) && @alarm_dirty
    end
    save_as_button = FXButton.new(tool_bar,
      "\tSave As ...\tSave alarm to a new file.",
      :icon => save_as_icon)
    save_as_button.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = (! @alarm.nil?) && @alarm_dirty
    end
    exit_button = FXButton.new(tool_bar,
      "\tExit\tExit the program.",
      :icon => exit_icon)

    # Edit Toolbar
    FXFrame.new(tool_bar,
      LAYOUT_TOP|LAYOUT_LEFT|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 8)
    edit_alarm_button = FXButton.new(tool_bar,
      "\tEdit\tEdit alarm.",
      :icon => edit_alarm_icon)
    edit_alarm_button.connect(SEL_UPDATE) do |sender, sel, data|
      sender.enabled = !@alarm.nil?
    end
    preferences_button = FXButton.new(tool_bar,
      "\tPreferences ...\tEdit system preferences.",
      :icon => preferences_icon)

    # Control Toolbar
    FXFrame.new(tool_bar,
      LAYOUT_TOP|LAYOUT_LEFT|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 8)
    previous_button = FXButton.new(tool_bar,
      "\tPrevious Step\tGoto previous step.",
      :icon => previous_icon)
    previous_button.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        !@counting_down ? sender.disable : sender.enable
      end
    end
    start_button = FXButton.new(tool_bar,
      "\tStart\tStart running alarm.",
      :icon => start_icon)
    start_button.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        @counting_down ? sender.disable : sender.enable
      end
    end
    next_button = FXButton.new(tool_bar,
      "\tNext Step\tGoto next step.",
      :icon => next_icon)
    next_button.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        !@counting_down ? sender.disable : sender.enable
      end
    end
    stop_button = FXButton.new(tool_bar,
      "\tStop\tStop running alarm.",
      :icon => stop_icon)
    stop_button.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        @counting_down ? sender.enable : sender.disable
      end
    end

    # Help Toolbar
    FXFrame.new(tool_bar,
      LAYOUT_TOP|LAYOUT_LEFT|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 8)
    previous_button = FXButton.new(tool_bar,
      "\tHelp\tGet help.",
      :icon => help_icon)
    about_button = FXButton.new(tool_bar,
      "\tAbout\tAbout LX's Alarm.",
      :icon => about_icon)
  end

  def add_status_bar
    FXStatusBar.new(self, :opts => LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X)
    FXToolTip.new(app)
  end

  def load_icon(filename)
    begin
      icon = nil
      filename = File.join("icons",filename)
      File.open(filename, "rb") do |io|
        icon = FXPNGIcon.new(app, io.read)
      end
      icon
    rescue
      raise RuntimeError, "Couldn't load icon: #{filename}"
    end
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
  
  def open_alarm_file(filepath)
    if @switcher.children.length >1
      @switcher.removeChild(@switcher.childAtIndex(1))
    end
    @alarm = YAML.load_file(filepath)
    #Creating alarm view from @alarm
#    AlarmView.new(@switcher,@alarm)
    @switcher.create
    @switcher.recalc
#    @switcher.setCurrent 1
#    @switcher.create
  end
  
  def store_alarm_file
  end

  def clean_up(component)
    component.children.each do |child|
      clean_up(child)
      component.removeChild(child)
    end
    #getApp().removeTimeouts()
  end

  def onCmdStopTimer(sender, sel, ptr)
    @counting_down = false
    if getApp().hasTimeout?(@timer)
      getApp().removeTimeout(@timer)
      @timer = nil
    end
  end
  def onTimeout(sender, sel, ptr)
   i = @alarm.countdown
   puts i
   if i != 0
     @timer = getApp().addTimeout(TIMER_INTERVAL, method(:onTimeout))
     @counting_down = false
   end
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    LXAlarm.new(app)
    app.create
    app.run
  end
end
