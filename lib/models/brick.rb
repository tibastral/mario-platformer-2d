class Brick
  attr_reader :x1, :x2, :y1, :y2

  def initialize(map, params)
    @map = map
    @x1 = params[:x1]
    @x2 = params[:x2]
    @y1 = params[:y1]
    @y2 = params[:y2]
    @color = params[:color]
    @texture = params[:texture]
    @texture_size_x = params[:texture_size_x]
    @texture_size_y = params[:texture_size_y]
  end

  def draw(window)
    @color ||= Gosu::Color::AQUA
    if @texture
      @sprite ||= Gosu::Image.load_tiles(window, "media/#{@texture}.png", @texture_size_x, @texture_size_y, true)
      texture = @sprite[0]
      draw_texture(window, texture, @texture_size_x, @texture_size_y)
    else
      window.draw_quad(
        window.scroll_x + x1, GameWindow::HEIGHT - y1, @color,
        window.scroll_x + x1, GameWindow::HEIGHT - y2, @color,
        window.scroll_x + x2, GameWindow::HEIGHT - y2, @color,
        window.scroll_x + x2, GameWindow::HEIGHT - y1, @color,
      )
    end
  end

  def draw_texture(window, texture, size_x, size_y)
    @white ||= Gosu::Color::WHITE
    ((y2 - y1) / size_y).times do |current_y|
      ((x2 - x1) / size_x).times do |current_x|
        texture.draw_as_quad(
          window.scroll_x + x1 + current_x * size_x,
          GameWindow::HEIGHT - y2 + current_y * size_y,
          @white,
          window.scroll_x + x1 + current_x * size_x,
          GameWindow::HEIGHT - y2 + (current_y + 1) * size_y,
          @white,
          window.scroll_x + x1 + (current_x + 1) * size_x,
          GameWindow::HEIGHT - y2 + (current_y + 1) * size_y,
          @white,
          window.scroll_x + x1 + (current_x + 1) * size_x,
          GameWindow::HEIGHT - y2 + current_y * size_y,
          @white,
          0
        )
      end
    end
  end
end
