class Enemy < Character

  self.x_size = 7
  self.y_size = 8
  self.max_normal_speed = 1
  self.lifes = 1
  self.acceleration = 0.4
  self.size_multiplier = 5

  def initialize(map, options)
    super(map, options)
    @color ||= Gosu::Color::BLUE
  end

  def ai!
    @moving_for ||= 1
    @direction ||= 1

    if @moving_for > 0
      @moving_for -= 1
      if @moving_for == 0
        @moving_for = 50 + rand(20)
        @direction = 2 * rand(2) - 1
      end
    end
    accelerate!(@direction)
  end

  def draw(window)
    @tile ||= Gosu::Image.load_tiles(window, 'media/ennemi.png', 7, 8, true)
    draw_sprite(@tile[0], window)
  end
end
