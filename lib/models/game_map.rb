class GameMap
  attr_accessor :characters, :bricks, :enemies

  def initialize(window)
    @window = window
    @characters = []
    @bricks = [
      Brick.new(self, x1: -1000, x2: 20, y1: -100, y2: 100),
      Brick.new(self, x1: -1000, x2: 5000, y1: 0, y2: 10)
    ]
    @enemies = [
      Enemy.new(self, x: 10, y: 30),
      Enemy.new(self, x: 10, y: 30),
      Enemy.new(self, x: 10, y: 30),
      Enemy.new(self, x: 10, y: 30)
    ]
    @characters = [
      Character.new(self, x: 500, y: 19, main: true)
    ]
  end

  def reset
    @window.reset
  end

  def move!
    @characters.map(&:move!)
    move_enemies!
  end

  def move_enemies!
    @enemies.each do |enemy|
      enemy.ai!
      enemy.move!
    end
  end

  def draw(window)
    [
      @characters,
      @bricks,
      @enemies
    ].each do |collection|
      collection.map{|e| e.draw(window)}
    end
  end
end
