class GameMap
  attr_accessor :characters, :bricks

  def initialize
    @characters = []
    @bricks = []
  end

  def move!
    @characters.map(&:move!)
  end
end
