class GameWindow < Hasu::Window
  WIDTH = 1024
  HEIGHT = 768
  JUMP_BUTTONS = [Gosu::GpButton2, Gosu::KbSpace]
  STEROIDS_BUTTONS = [Gosu::GpButton3, Gosu::KbLeftShift, Gosu::KbRightShift]

  def initialize
    super(WIDTH, HEIGHT, false)
  end

  def reset
    @character = Character.new(self)
    @bricks = [
      Brick.new(x1: -1000, x2: 20, y1: -100, y2: 100),
      Brick.new(x1: -1000, x2: 5000, y1: 0, y2: 10),
      Brick.new(x1: -1000, x2: 100, y1: 100, y2: 200)
    ]
  end

  def buttons_down?(buttons)
    res = false
    buttons.each do |button|
      res ||= button_down?(button)
    end
    res
  end

  def update
    if button_down? Gosu::KbEscape
      close
    end
    handle_direction

    if buttons_down? JUMP_BUTTONS
      @character.jump!
    end
    @character.move!
    @character.handle_collisions(@bricks)
  end

  def handle_direction
    if buttons_down? STEROIDS_BUTTONS
      @character.steroidsSpeed!
    else
      @character.normalSpeed!
    end
    if button_down?(Gosu::GpRight) || button_down?(Gosu::KbRight)
      @character.accelerate!(1)
    elsif button_down?(Gosu::GpLeft) || button_down?(Gosu::KbLeft)
      @character.accelerate!(-1)
    else
      @character.inertia_x!
    end
  end

  def button_up(id)
    if JUMP_BUTTONS.include?(id)
      @character.stop_jump!
    end
  end

  def draw
    @character.draw(self)
    @bricks.map{|e| e.draw(self)}
  end
end
