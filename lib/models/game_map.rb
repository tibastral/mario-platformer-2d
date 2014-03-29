class GameMap
  attr_accessor :characters, :bricks, :enemies

  def initialize(window)
    @window = window
    @characters = []
    @bricks = []
    @enemies = []
  end

  def reset
    @window.reset
  end

  def move!
    @characters.map(&:move!)
  end
end
