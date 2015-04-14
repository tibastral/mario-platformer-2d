class Brick
  attr_reader :x1, :x2, :y1, :y2

  def initialize(map, params)
    @map = map
    @x1 = params[:x1]
    @x2 = params[:x2]
    @y1 = params[:y1]
    @y2 = params[:y2]
    @color = params[:color]
  end

  def draw(window)
    @color ||= Gosu::Color::AQUA
    window.draw_quad(
      window.scroll_x + x1, GameWindow::HEIGHT - y1, @color,
      window.scroll_x + x1, GameWindow::HEIGHT - y2, @color,
      window.scroll_x + x2, GameWindow::HEIGHT - y2, @color,
      window.scroll_x + x2, GameWindow::HEIGHT - y1, @color,
    )
  end
end
