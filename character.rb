class Character
  attr_reader :x, :y, :dx, :dy, :a_gravity, :ay, :is_jumping

  SIZE = 32
  MAX_SPEED = 5
  ACCELERATION = 0.4
  GRAVITY = 7
  JUMPING_VELOCITY = 15
  CAN_JUMP_FOR_MS = 10
  X_INIT = 20
  MAX_JUMPS = 2

  def initialize
    @x = X_INIT
    @y = GameWindow::WIDTH / 2
    @dx = 0.0
    @dy = 0.0
    @ay = 0.0
    @nb_jumps = 0
    @gravity = -1.0
    @max_speed = 5
    @is_possible_to_jump = true
  end

  def x1; @x - SIZE / 2; end
  def x2; @x + SIZE / 2; end
  def y1; @y - SIZE / 2; end
  def y2; @y + SIZE / 2; end

  def move_x!
    @x += @dx
  end

  def move!
    move_x!
    move_y!
  end

  def can_continue_jumping?
    (Gosu::milliseconds - @begin_jump_at).to_i < CAN_JUMP_FOR_MS * @dx.abs
  end

  def jump!
    unless @begin_jump_at
      @begin_jump_at = Gosu::milliseconds
    end
    if can_continue_jumping? && @nb_jumps < MAX_JUMPS
      @dy = JUMPING_VELOCITY
    end
  end

  def stop_jump!
    @begin_jump_at = nil
    @nb_jumps += 1
  end

  def ay_total
    @ay + @gravity
  end

  def move_y!
    @dy += ay_total
    @y += @dy
    if @y < 16
      @nb_jumps = 0
      @y = 16
      @dy = 0
    end
  end

  def normalSpeed!
    @max_speed = 5
  end

  def steroidsSpeed!
    @max_speed = 10
  end

  def inertia_x!
    @dx /= 1.10
  end

  def accelerate!(direction)
    @dx += direction * ACCELERATION
    if @dx > @max_speed
      @dx = @max_speed
    elsif @dx < -@max_speed
      @dx = -@max_speed
    end
  end

  def draw(window)
    color = Gosu::Color::RED
    window.draw_quad(
      x1, GameWindow::HEIGHT - y1, color,
      x1, GameWindow::HEIGHT - y2, color,
      x2, GameWindow::HEIGHT - y2, color,
      x2, GameWindow::HEIGHT - y1, color,
    )
  end
end
