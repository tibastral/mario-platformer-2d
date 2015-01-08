class GameMap
  attr_accessor :characters, :bricks, :enemies, :window

  def initialize(window)
    @window = window
    @bricks = [
      Brick.new(self, x1: -1000, x2: 20, y1: -100, y2: 100),
      Brick.new(self, x1: -1000, x2: 5000, y1: 0, y2: 10),
      Brick.new(self, x1: -1000, x2:-500, y1:0, y2:500),
      Brick.new(self, x1: 100, x2: 1000, y1: 100, y2: 520),
      Brick.new(self, x1: 500, x2: 520, y1: 120, y2: 300)
    ]
    @enemies = [
      Enemy.new(self, x: 50, y: 200, life: 1),
      Enemy.new(self, x: 10, y: 200, life: 1),
      # Enemy.new(self, x: 10, y: 30),
      # Enemy.new(self, x: 10, y: 30)
    ]
    @characters = [
      MainCharacter.new(self, x: 500, y: 26, life: 3)
    ]
  end

  def reset
    @window.reset
  end

  def move!
    @characters.map(&:move!)
    move_enemies!
    @enemies = @enemies.reject{ |e| e.dead? }
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
