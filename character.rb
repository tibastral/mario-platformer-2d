class Object
  def present?
    !nil?
  end
end

class Character
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

  def handle_collision(brick)
    if right_y > brick.left_y && left_y < brick.right_y && x1 > brick.x1 && x2 < brick.x2
      # min_overlap_y = [(y2 - brick.y1).abs, (y1 - brick.y2).abs].min
      # min_overlap_x = [(x1 - brick.x1).abs, (x2 - brick.x2).abs].min
      #
      # if min_overlap_y < min_overlap_x
        if @velocity_y < 0
          @velocity_y = 0
          @y = brick.y2 + Y_SIZE / 2
          @nb_jumps = 0
        else
          @velocity_y = 0
          @y = brick.y1 - Y_SIZE / 2
        end
        if y2 > brick.y1 && y1 < brick.y2 && x1 > brick.x1 && x2 < brick.x2
          if @velocity_x < 0
            @x = brick.x2 + X_SIZE / 2
            @velocity_x = 0
          elsif @velocity_x > 0
            @velocity_x = 0
            @x = brick.x1 + X_SIZE / 2
          end
        end
    end
  end

  def handle_collisions(bricks)
    bricks.each do |brick|
      handle_collision(brick)
    end
  end

  def initialize(window)
    @x = X_INIT
    @y = Y_INIT
    @velocity_x = 0.1
    @velocity_y = 0.0
    @nb_jumps = 0
    @gravity = GRAVITY
    @max_speed = 5
    @jump_sound = Gosu::Sample.new(window, "media/jump.wav")
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
  end

  def time_since_beginning_of_jump_in_ms
    (Gosu::milliseconds - @begin_jump_at).to_i
  end

  def can_continue_jumping?
    puts CAN_JUMP_FOR_MS * @velocity_x.abs
    time_since_beginning_of_jump_in_ms < CAN_JUMP_FOR_MS * @velocity_x.abs
  end

  def jump!
    unless @begin_jump_at
      @jump_sound.play
      @begin_jump_at = Gosu::milliseconds
    end
    if can_continue_jumping? && @nb_jumps < MAX_JUMPS
      @velocity_y = JUMPING_VELOCITY
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
    @max_speed = 100
  end

  def inertia_x!
    if jumping?
      @velocity_x /= FROTTEMENT_AIR
    else
      @velocity_x /= FROTTEMENT_TERRE
    end
  end

  def accelerate!(direction)
    @velocity_x += direction * ACCELERATION
    if @velocity_x > @max_speed
      @velocity_x = @max_speed
    elsif @velocity_x < -@max_speed
      @velocity_x = -@max_speed
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
