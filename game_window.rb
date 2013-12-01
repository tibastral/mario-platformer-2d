class GameWindow < Hasu::Window
  WIDTH = 640
  HEIGHT = 480

  def initialize
    super(WIDTH, HEIGHT, false)
  end

  def reset
    @character = Character.new
    # @bricks = [Brick.new(x1: 1, y1: 1, x2: 2, y2: 2)]
  end

  def draw
    @character.draw(self)
  end

  def update
    if button_down? Gosu::KbEscape
      close
    end
    handle_direction
    if button_down? Gosu::GpButton2
      @character.jump!
    end
    @character.move!
  end

  def handle_direction
    if button_down? Gosu::GpButton3
      @character.steroidsSpeed!
    else
      @character.normalSpeed!
    end
    if button_down? Gosu::GpRight
      @character.accelerate!(1)
    elsif button_down? Gosu::GpLeft
      @character.accelerate!(-1)
    else
      @character.inertia_x!
    end
  end

  def button_up(id)
    if id == Gosu::GpButton2
      @character.stop_jump!
    end
  end
end