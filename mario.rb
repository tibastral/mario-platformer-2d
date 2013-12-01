require "hasu"

Hasu.load "character.rb"

class GameWindow < Hasu::Window
  WIDTH = 640
  HEIGHT = 480

  def initialize
    super(WIDTH, HEIGHT, false)
  end

  def reset
    @character = Character.new
  end

  def draw
    @character.draw(self)
  end

  def update
    @character.move!
    handle_direction
    if button_down? Gosu::GpButton2
      @character.jump!
    end
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

GameWindow.run