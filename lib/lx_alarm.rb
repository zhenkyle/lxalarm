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
    super(app,"LX's Alarm: An Alarm with step settings", :width => 600, :height => 400)
    add_menu_bar
    add_tool_bar
   
    @switcher = FXSwitcher.new(self, :opts => LAYOUT_FILL)
    
    #Creating Welcome View
    @welcome_view =WelcomeView.new(@switcher)
    
    #for test
    @alarm = YAML.load_file("cook_a_cake.alm")
    AlarmView.new(@switcher,@alarm)
    @switcher.setCurrent 1
end
  
  
  def add_menu_bar
    menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
    
    # File Menu
    file_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "File", :popupMenu => file_menu)
    open_cmd = FXMenuCommand.new(file_menu, "Open...")
    open_cmd.connect(SEL_COMMAND) do
      dialog = FXFileDialog.new(self, "Open an Alarm")
      dialog.selectMode = SELECTFILE_EXISTING
      dialog.patternList = ["Alarm Files (*.alm)"]
      if dialog.execute != 0
        open_alarm_file(dialog.filename)
      end
    end

    new_alarm_command = FXMenuCommand.new(file_menu, "New Alarm...")
    new_alarm_command.connect(SEL_COMMAND) do
      alarm_title =
        FXInputDialog.getString("My Alarm", self, "New Alarm", "Name:")
      if alarm_title
        @alarm = Alarm.new(alarm_title)
      end
    end

    exit_cmd = FXMenuCommand.new(file_menu, "Exit")

    exit_cmd.connect(SEL_COMMAND) do
      store_alarm_file
      clean_up(self)
      exit
    end
    # Alarm Menu
    alarm_menu = FXMenuPane.new(self)
    FXMenuTitle.new(menu_bar, "Alarm", :popupMenu => alarm_menu)
    start_cmd = FXMenuCommand.new(alarm_menu, "Start")
    start_cmd.connect(SEL_COMMAND) do
      @countingdown = true
      getApp().addTimeout(TIMER_INTERVAL, method(:onTimeout))
    end
    start_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      @countingdown ? sender.disable : sender.enable
    end
    stop_cmd = FXMenuCommand.new(alarm_menu, "Stop")
    stop_cmd.connect(SEL_COMMAND, method(:onCmdStopTimer))
    stop_cmd.connect(SEL_UPDATE) do |sender, sel, ptr|
      @countingdown ? sender.enable : sender.disable
    end

    # Initialize private variables
    @countingdown = false
    @timer = nil
  end

  def add_tool_bar

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
    getApp().removeTimeouts()
  end

  def onCmdStopTimer(sender, sel, ptr)
    @countingdown = false
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
     @countingdown = false
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
