class Enemy < Character

  self.x_size = 32
  self.y_size = 36
  self.max_normal_speed = 1

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
    @tile[0].draw(window.scroll_x + x1, GameWindow::HEIGHT - y1 - y_size, 1, 5, 5)
  end
end
