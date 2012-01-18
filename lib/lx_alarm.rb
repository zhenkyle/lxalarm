require 'fox16'
include Fox

# require basics
require 'ext_integer'
require 'time_period'
require 'alarm'
require 'yaml'

# require views
require 'time_period_view'
require 'alarm_view'
require 'welcome_view'


class LXAlarm < FXMainWindow
  def initialize(app)
    super(app,"LX's Alarm: An Alarm with time period settings", :width => 600, :height => 400)
    add_menu_bar
   
    begin
      @alarm = YAML.load_file("cook_a_cake.yml")
    rescue
      @alarm = Alarm.new("Cook a Cake")
      @alarm << TimePeriod.new("Mix Flour", 20)
      @alarm << TimePeriod.new("Shape the Cake", 10)
      @alarm << TimePeriod.new("Roaste the Cake", 15)
    end
    
    @switcher = FXSwitcher.new(self, :opts => LAYOUT_FILL)
    
    #Creating Welcome View
    @welcome_view =WelcomeView.new(@switcher)
    #Creating alarm view from @alarm
    @alarm_view = AlarmView.new(@switcher,@alarm)
end
  
  
  def add_menu_bar
    menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
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
      exit
    end

  end
  
  def create
    super
    show(PLACEMENT_SCREEN)
  end
  
  def open_alarm_file
  end
  
  def store_alarm_file
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    LXAlarm.new(app)
#    app.addTimeout(1*1000, :repeat => true) do
#      puts "hahaha"
#    end
    app.create
    app.run
  end
end
