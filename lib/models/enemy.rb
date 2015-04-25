class Enemy < Character

  self.current_x_size = 35
  self.current_y_size = 40
  self.x_normal_size = 35
  self.y_normal_size = 40
  self.max_normal_speed = 1
  self.lifes = 1
  self.acceleration = 0.2
  self.size_multiplier = 1

  def initialize(map, options)
    super(map, options)
  end

  def ai!
    @moving_for ||= 1
    @direction ||= 1

    if @moving_for > 0
      @moving_for -= 1
      if @moving_for == 0
        @moving_for = 50 + rand(20)
        @direction = [-1, 1].sample
      end
    end
    accelerate!(@direction)
  end

  def draw(window)
    @tile ||= Gosu::Image.load_tiles(window, 'media/ennemi.png', current_x_size, current_y_size, true)
    draw_sprite(@tile[0], window)
  end
end
