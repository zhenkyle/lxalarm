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
require 'setting_view'


class LXAlarm < FXMainWindow
  
  # How often our timer will fire (in milliseconds)
  TIMER_INTERVAL = 1000
  
  def initialize(app)
    super(app,"LX's Alarm: An Alarm with step settings", :width => 700, :height => 500)
    # Make all menu
    add_menu_bar

    # Make all tool bar
    add_tool_bar

    # Make a status bar
    FXStatusBar.new(self, :opts => LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X)
    
    # Make tab book
    add_tab_book


    # Make a tool tip
    FXToolTip.new(app)
   
    # Initialize private variables
    @alarm = nil
    @counting_down = false
    @filename = nil

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
    new_alarm_cmd = FXMenuCommand.new(file_menu, "New")
    new_alarm_cmd.connect(SEL_COMMAND, method(:on_cmd_file_new))

    # File Menu -- Open...
    open_cmd = FXMenuCommand.new(file_menu, "Open...")
    open_cmd.connect(SEL_COMMAND, method(:on_cmd_file_open)) 

    # File Menu -- Seperator
    FXMenuSeparator.new(file_menu)

    # File Menu -- Save
    save_cmd = FXMenuCommand.new(file_menu, "Save")
    save_cmd.connect(SEL_COMMAND, method(:on_cmd_file_save))
    save_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_dirty))

    # File Menu -- Save As ...
    save_as_cmd = FXMenuCommand.new(file_menu, "Save As ...")
    save_as_cmd.connect(SEL_COMMAND, method(:on_cmd_file_save_as))
    save_as_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_dirty))

    # File Menu -- Seperator
    FXMenuSeparator.new(file_menu)

    # File Menu -- Close
    close_cmd = FXMenuCommand.new(file_menu, "Close")
    close_cmd.connect(SEL_COMMAND, method(:on_cmd_file_close))
    close_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_open))

    # File Menu -- Exit
    exit_cmd = FXMenuCommand.new(file_menu, "Exit")
    exit_cmd.connect(SEL_COMMAND, method(:on_cmd_file_exit))

    # Edit Menu
    edit_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Edit", :popupMenu => edit_menu)

    # Edit Menu -- Edit Alarm
    set_alarm_cmd = FXMenuCommand.new(edit_menu, "Set Alarm")
    set_alarm_cmd.connect(SEL_COMMAND, method(:on_cmd_edit_set_alarm))
    set_alarm_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_open))

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
    start_cmd.connect(SEL_COMMAND, method(:on_cmd_control_start))
    start_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      if @alarm.nil?
        sender.disable
      else
        @counting_down ? sender.disable : sender.enable
      end
    end

    # Control Menu -- Stop
    stop_cmd = FXMenuCommand.new(control_menu, "Stop")
    stop_cmd.connect(SEL_COMMAND, method(:on_cmd_control_stop))
    stop_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_running))

    # Control Menu -- Seperator
    FXMenuSeparator.new(control_menu)

    # Control Menu -- Previous Step
    previous_cmd = FXMenuCommand.new(control_menu, "Previous Step")
    previous_cmd.connect(SEL_COMMAND) do
    end
    previous_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_running))

    # Control Menu -- Pause
    pause_cmd = FXMenuCommand.new(control_menu, "Pause")
    pause_cmd.connect(SEL_COMMAND) do
    end
    pause_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_running))

    # Control Menu -- Next Step
    next_cmd = FXMenuCommand.new(control_menu, "Next Step")
    next_cmd.connect(SEL_COMMAND) do
    end
    next_cmd.connect(SEL_UPDATE, method(:on_upd_alarm_running))

    # Help Menu
    help_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Help", :popupMenu => help_menu)

    # Help Menu -- Help
    help_cmd = FXMenuCommand.new(help_menu, "Help")
    help_cmd.connect(SEL_COMMAND) do
    end

    # Help Menu -- About
    about_cmd = FXMenuCommand.new(help_menu, "About LX's Alarm")
    about_cmd.connect(SEL_COMMAND, method(:on_cmd_help_about))
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
    close_icon = load_icon("archive-icon.png")
    exit_icon = load_icon("exit-icon.png")
    set_alarm_icon = load_icon("notebook-icon.png")
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
    new_button.connect(SEL_COMMAND, method(:on_cmd_file_new))
    
    open_button = FXButton.new(tool_bar,
      "\tOpen ...\tOpen an alarm from file.",
      :icon => open_icon)
    open_button.connect(SEL_COMMAND, method(:on_cmd_file_open))
    
    save_button = FXButton.new(tool_bar,
      "\tSave\tSave alarm.",
      :icon => save_icon)
    save_button.connect(SEL_UPDATE, method(:on_upd_alarm_dirty))
    save_button.connect(SEL_COMMAND, method(:on_cmd_file_save))
    
    save_as_button = FXButton.new(tool_bar,
      "\tSave As ...\tSave alarm to a new file.",
      :icon => save_as_icon)
    save_as_button.connect(SEL_UPDATE, method(:on_upd_alarm_dirty))
    save_as_button.connect(SEL_COMMAND, method(:on_cmd_file_save_as))
    
    close_button = FXButton.new(tool_bar,
      "\tClose\tClose opened Alarm.",
      :icon => close_icon)
    close_button.connect(SEL_UPDATE, method(:on_upd_alarm_open))
    close_button.connect(SEL_COMMAND, method(:on_cmd_file_close))
    
    exit_button = FXButton.new(tool_bar,
      "\tExit\tExit the program.",
      :icon => exit_icon)
    exit_button.connect(SEL_COMMAND, method(:on_cmd_file_exit))

    # Edit Toolbar
    FXFrame.new(tool_bar,
      LAYOUT_TOP|LAYOUT_LEFT|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 8)
    set_alarm_button = FXButton.new(tool_bar,
      "\tSet Alarm\tChang alarm setting.",
      :icon => set_alarm_icon)
    set_alarm_button.connect(SEL_COMMAND, method(:on_cmd_edit_set_alarm))
    set_alarm_button.connect(SEL_UPDATE) do |sender, sel, data|
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
    start_button.connect(SEL_COMMAND, method(:on_cmd_control_start))
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
    stop_button.connect(SEL_COMMAND, method(:on_cmd_control_stop))
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
    about_button.connect(SEL_COMMAND, method(:on_cmd_help_about))
  end

  def add_tab_book
    @tabbook = FXTabBook.new(self,:opts => LAYOUT_FILL)
    
    welcome_tab = FXTabItem.new(@tabbook,"Welcome")
    welcome_page = WelcomeView.new(@tabbook, FRAME_RAISED|LAYOUT_FILL)
  end
  

  # A function to load png icons
  def load_icon(filename)
    icon = nil
    filename = File.join("icons",filename)
    File.open(filename, "rb") do |io|
      icon = FXPNGIcon.new(app, io.read)
    end
    icon.blend(FXRGB(236,233,216))
    icon
  end

  # Create and show the main window
  def create
    super
    show(PLACEMENT_SCREEN)
  end

  # Menu / Button command events
  def on_cmd_file_new(sender,selector,data)
  	if @alarm != nil
  	  rtn_value = on_cmd_file_close(sender,selector,data)
  	  return if rtn_value == -1
 	end

    @alarm = Alarm.new("Untitled Alarm")
    @alarm.dirty = true
    @alarm << Step.new("Step 1",60)
    generate_tabbook
  	@tabbook.setCurrent(2)
  end

  def on_cmd_file_open(sender,selector,data)
  	if @alarm != nil
  	  rtn_value = on_cmd_file_close(sender,selector,data)
  	  return if rtn_value == -1
 	end
    dialog = FXFileDialog.new(self, "Open an Alarm")
    dialog.selectMode = SELECTFILE_EXISTING
    dialog.patternList = ["Alarm Files (*.alm)"]
    if dialog.execute != 0
      @filename = dialog.filename
      @alarm = YAML.load_file(@filename)
    end
    generate_tabbook
    @tabbook.setCurrent(1)
  end

  def on_cmd_file_save(sender,selector,data)
  	if @filename == nil
  	  on_cmd_file_save_as(sender,selector,data)
  	else
  	  save_alarm_file(@filename)
  	  @alarm.dirty = false
  	end
  end

  def on_cmd_file_save_as(sender,selector,data)
  	dialog = FXFileDialog.new(self,"Save as ")
    dialog.patternList = ["Alarm Files (*.alm)"]
    if dialog.execute != 0
      @filename = dialog.filename
      if File.extname(@filename) != ".alm"
      	@filename += ".alm"
  	  end
      save_alarm_file(@filename)
      @alarm.dirty = false
    end
  end
  
  def on_cmd_file_close(sender,selector,data)
    if @alarm.dirty == true
      answer = FXMessageBox.question(self, MBOX_YES_NO_CANCEL,
        "LX's alarm",
        "This file is unsaved.\n Do you want to save it?")
      if answer == MBOX_CLICKED_CANCEL
      	return -1
      elsif answer == MBOX_CLICKED_YES
        on_cmd_file_save(sender,selector,data)
      end
    end
    if ! @alarm.nil?
      @tabbook.removeChild(@tabbook.childAtIndex(5))
      @tabbook.removeChild(@tabbook.childAtIndex(4))
      @tabbook.removeChild(@tabbook.childAtIndex(3))
      @tabbook.removeChild(@tabbook.childAtIndex(2))
      @filename = nil
      @alarm = nil
    end
    return 0
  end
  
  def on_cmd_file_exit(sender,selector,data)

    clean_up(self)
    exit
  end
  
  def on_cmd_edit_set_alarm(sender,selector,data)
  	@tabbook.setCurrent(2)
  end
  
  def on_cmd_control_start(sender,selector,data)
    @counting_down = true
    getApp().addTimeout(TIMER_INTERVAL, method(:on_timeout))
  end

  def on_cmd_control_stop(sender,selector,data)
    @counting_down = false
    if getApp().hasTimeout?(@timer)
      getApp().removeTimeout(@timer)
      @timer = nil
    end
  end

  def on_cmd_help_about(sender,selector,data)
    FXMessageBox.information(self, MBOX_OK, "About LX's Alarm",
      "LX's Alarm.\nCopyright (C) 2012 Zhen Ke")
  end

  # Menu / Button update events
  def on_upd_alarm_open(sender,selector,data)
    sender.enabled = ! @alarm.nil?
  end

  def on_upd_alarm_dirty(sender,selector,data)
    sender.enabled = (!@alarm.nil?) && @alarm.dirty
  end

  def on_upd_alarm_running(sender,selector,data)
    if @alarm.nil?
      sender.disable
    else
      @counting_down ? sender.enable : sender.disable
    end
  end


  # Working Fuctions
  def generate_tabbook
    alarm_view_tab = FXTabItem.new(@tabbook, "Alarm View")
    alarm_view_page = AlarmView.new(@tabbook,@alarm,FRAME_RAISED|LAYOUT_FILL)
    alarm_set_tab = FXTabItem.new(@tabbook, "Alarm Set")
    alarm_set_page = SettingView.new(@tabbook, @alarm, FRAME_RAISED|LAYOUT_FILL)
    @tabbook.create
  end

  def save_alarm_file(filepath)
  	@alarm.dirty = false
    File.open(filepath,"w") do |io|
      io.write(YAML.dump(@alarm))
    end
  end

  def clean_up(component)
    component.children.each do |child|
      clean_up(child)
      component.removeChild(child)
    end
    #TODO
    #getApp().removeTimeouts()
  end

  def on_timeout(sender, sel, ptr)
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
