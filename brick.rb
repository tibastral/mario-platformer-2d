class Brick
  attr_reader :x1, :x2, :y1, :y2

  def initialize(params)
    @x1 = params[:x1]
    @x2 = params[:x2]
    @y1 = params[:y1]
    @y2 = params[:y2]
  end

  def top_x
    x1
  end

  def left_y
    y1
  end

  def bottom_x
    x2
  end

  def right_y
    y2
  end

  def draw(window)
    color = Gosu::Color::AQUA
    window.draw_quad(
      x1, GameWindow::HEIGHT - y1, color,
      x1, GameWindow::HEIGHT - y2, color,
      x2, GameWindow::HEIGHT - y2, color,
      x2, GameWindow::HEIGHT - y1, color,
    )
  end
end
