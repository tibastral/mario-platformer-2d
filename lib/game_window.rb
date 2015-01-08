class GameWindow < Hasu::Window
  WIDTH = 1024
  HEIGHT = 768
  JUMP_BUTTONS = [Gosu::GpButton2, Gosu::KbSpace]
  STEROIDS_BUTTONS = [Gosu::GpButton3, Gosu::KbLeftShift, Gosu::KbRightShift]

  def initialize
    super(WIDTH, HEIGHT, false)
    @scroll_x = 0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  attr_accessor :scroll_x, :font

  def reset
    @map = GameMap.new(self)
    @character = @map.characters.first
  end

  def buttons_down?(buttons)
    res = false
    buttons.each do |button|
      res ||= button_down?(button)
    end
    res
  end

  def update
    handle_quit
    handle_direction
    if buttons_down? JUMP_BUTTONS
      @character.jump!
    end
    @map.move!
  end

  def button_up(id)
    if JUMP_BUTTONS.include?(id)
      @character.stop_jump!
    end
  end

  def draw
    @map.draw(self)
  end

  private

  def handle_quit
    if button_down? Gosu::KbEscape
      close
    end
  end
    
  def handle_direction
    if buttons_down? STEROIDS_BUTTONS
      @character.steroidsSpeed!
    else
      @character.normalSpeed!
    end
    if buttons_down? [Gosu::GpRight, Gosu::KbRight]
      @character.accelerate!(1)
    elsif buttons_down? [Gosu::GpLeft, Gosu::KbLeft]
      @character.accelerate!(-1)
    else
      @character.inertia_x!
    end
    @scroll_x = @character.scroll_x
  end

end
