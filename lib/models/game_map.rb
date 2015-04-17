class GameMap
  attr_accessor :characters, :bricks, :platforms, :enemies, :window

  def initialize(window)
    @window = window
    @platforms = [
      Platform.new(self, x1: -400, x2: -350, y1: 200, y2: 210, color: Gosu::Color::YELLOW),
      Platform.new(self, x1: -300, x2: -200, y1: 350, y2: 360, color: Gosu::Color::YELLOW)
    ]
    @bricks = [
      #Brick.new(self, x1: -10000, x2: 10000, y1: -10000, y2: 10000, color: Gosu::Color::GRAY),
      Brick.new(self, x1: -1000, x2: 20, y1: -100, y2: 100),
      Brick.new(self, x1: -1000, x2: 5000, y1: 0, y2: 10),
      Brick.new(self, x1: 1000, x2: 1100, y1: 0, y2: 20),
      Brick.new(self, x1: -1000, x2:-500, y1:0, y2:500),
      Brick.new(self, x1: 100, x2: 1000, y1: 150, y2: 520),
      Brick.new(self, x1: 600, x2: 720, y1: 120, y2: 300)
    ]
    @enemies = [
      Enemy.new(self, x: 50, y: 200, life: 1),
      Enemy.new(self, x: 10, y: 200, life: 1),
      # Enemy.new(self, x: 10, y: 30),
      # Enemy.new(self, x: 10, y: 30)
    ]
    @characters = [
      MainCharacter.new(self, x: 500, y: 100, life: 3)
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
      @platforms,
      @enemies
    ].each do |collection|
      collection.map{|e| e.draw(window)}
    end
  end
end
