class Object
  def present?
    !nil?
  end
end

class Character
  attr_accessor :x, :y, :velocity_x, :velocity_y

  X_SIZE = 16
  Y_SIZE = 32
  MAX_SPEED = 5
  ACCELERATION = 0.4
  GRAVITY = -1
  JUMPING_VELOCITY = 15
  CAN_JUMP_FOR_MS = 10
  X_INIT = 100
  Y_INIT = 10
  MAX_JUMPS = 2
  FROTTEMENT_TERRE = 1.10
  FROTTEMENT_AIR = 1.0005
  WINDOW_HALF_SIZE = 512

  def scroll_x
    WINDOW_HALF_SIZE - x1
  end

  def collision?(brick)
    x2 > brick.x1 &&
    x1 < brick.x2 &&
    y1 < brick.y2 &&
    y2 > brick.y1
  end

  def handle_collision(brick)
    if collision?(brick)
      overlap_x = [x2, brick.x2].min - [x1, brick.x1].max
      overlap_y = [y2, brick.y2].min - [y1, brick.y1].max

      if overlap_y.abs < overlap_x.abs
        @velocity_y = 0
        @y += overlap_y
        @nb_jumps = 0
      else
        @velocity_x = 0.001
        @x += overlap_x
      end
    end
  end

  def handle_collisions
    @map.bricks.each do |brick|
      handle_collision(brick)
    end
  end

  def initialize(map)
    @map = map
    @x = X_INIT
    @y = Y_INIT
    @velocity_x = 0.1
    @velocity_y = 0.0
    @nb_jumps = 0
    @gravity = GRAVITY
    @max_speed = 5
  end

  def x1; @x - X_SIZE / 2; end
  def x2; @x + X_SIZE / 2; end
  def y1; @y - Y_SIZE / 2; end
  def y2; @y + Y_SIZE / 2; end

  def move_x!
    @x += @velocity_x
  end

  def move!
    move_x!
    move_y!
    handle_collisions
  end

  def time_since_beginning_of_jump_in_ms
    (Gosu::milliseconds - @begin_jump_at).to_i
  end

  def can_continue_jumping?
    time_since_beginning_of_jump_in_ms < CAN_JUMP_FOR_MS * @velocity_x.abs
  end

  def jump!
    if @nb_jumps < MAX_JUMPS
      unless @begin_jump_at.present?
        @jump_sound.play
        @begin_jump_at = Gosu::milliseconds
      end
      if can_continue_jumping?
        @velocity_y = JUMPING_VELOCITY
      end
    end
  end


  def jumping?
    @velocity_y.abs > 0
  end

  def stop_jump!
    @begin_jump_at = nil
    @nb_jumps += 1
  end

  def move_y!
    @velocity_y += @gravity
    @y += @velocity_y
  end

  def normalSpeed!
    @max_speed = 5
  end

  def steroidsSpeed!
    @max_speed = 10
  end

  def frottement
    jumping? ? FROTTEMENT_AIR : FROTTEMENT_TERRE
  end

  def inertia_x!
    @velocity_x /= frottement
  end

  def accelerate!(direction)
    @velocity_x += direction * ACCELERATION
    if @velocity_x > @max_speed || @velocity_x < -@max_speed
      @velocity_x /= frottement
    end
  end

  def draw(window)
    @window ||= window
    @jump_sound = Gosu::Sample.new(window, "media/jump.wav")
    color = Gosu::Color::RED
    window.draw_quad(
      window.scroll_x + x1, GameWindow::HEIGHT - y1, color,
      window.scroll_x + x1, GameWindow::HEIGHT - y2, color,
      window.scroll_x + x2, GameWindow::HEIGHT - y2, color,
      window.scroll_x + x2, GameWindow::HEIGHT - y1, color,
    )
  end
end
