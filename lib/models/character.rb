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
  MAX_STEROIDS_SPEED = 10
  MAX_JUMP_MULTIPLICATOR = 1.5
  ACCELERATION = 0.4
  GRAVITY = -1
  JUMPING_VELOCITY = 15
  CAN_JUMP_FOR_MS = 50
  X_INIT = 100
  Y_INIT = 10
  MAX_JUMPS = 2
  FROTTEMENT_TERRE = 1.10
  FROTTEMENT_AIR = 1.0005
  WINDOW_HALF_SIZE = 512

  def initialize(map, options={})
    @map = map
    @x = options[:x] || X_INIT
    @y = options[:y] || Y_INIT
    @previous_x = nil
    @previous_y = nil
    @velocity_x = 0.0
    @velocity_y = 0.0
    @nb_jumps = 0
    @gravity = GRAVITY
    @life = options[:life]
    @dead = false
  end

  def x1; @x - X_SIZE / 2; end
  def x2; @x + X_SIZE / 2; end
  def y1; @y - Y_SIZE / 2; end
  def y2; @y + Y_SIZE / 2; end

  def previous_x1; @previous_x - X_SIZE / 2; end
  def previous_x2; @previous_x + X_SIZE / 2; end
  def previous_y1; @previous_y - Y_SIZE / 2; end
  def previous_y2; @previous_y + Y_SIZE / 2; end

  def scroll_x
    WINDOW_HALF_SIZE - x1
  end

  def collision?(object)
    x2 > object.x1 &&
    x1 < object.x2 &&
    y1 < object.y2 &&
    y2 > object.y1
  end

  def handle_collision_with_brick!(brick, options={})
    if collision?(brick)
      came_from_up     = previous_y1 >= brick.y2
      came_from_down   = previous_y2 <= brick.y1
      came_from_right  = previous_x1 >= brick.x2
      came_from_left   = previous_x2 <= brick.x1

      rebound_speed = options[:rebound_speed] || 0

      if came_from_up
        @nb_jumps = 0
        move_out_of!(brick, :up)
        @velocity_y = 0
      end

      if came_from_down
        move_out_of!(brick, :down)
        @velocity_y = 0
      end

      if came_from_right
        move_out_of!(brick, :right)
        @velocity_x = rebound_speed
      end

      if came_from_left
        move_out_of!(brick, :left)
        @velocity_x = -rebound_speed
      end

    end
  end

  def handle_collisions_with_bricks!
    @map.bricks.each do |brick|
      handle_collision_with_brick!(brick)
    end
  end

  def move_x!
    @x += @velocity_x
  end

  def move!
    @previous_x = @x
    @previous_y = @y
    move_x!
    move_y!
    handle_collisions_with_bricks!
  end

  def can_move_out_of?(object, side)
    tmp_character = Character.new(nil, x: @x, y: @y)
    tmp_character.move_out_of!(object, side)

    collision_detected = @map.bricks.reduce(false) { | c, brick |
      c || tmp_character.collision?(brick)
    }

    return !collision_detected
  end

  def move_out_of!(object, side)
      if side == :up
      @y = object.y2 + Y_SIZE / 2
    end

      if side == :down
      @y = object.y1 - Y_SIZE / 2
    end

      if side == :right
      @x = object.x2 + X_SIZE / 2
    end

      if side == :left
      @x = object.x1 - X_SIZE / 2
    end
  end

  def time_since_beginning_of_jump_in_ms
    (Gosu::milliseconds - @begin_jump_at).to_i
  end

  def jump_multiplicator
    @velocity_x.abs > MAX_JUMP_MULTIPLICATOR ? MAX_JUMP_MULTIPLICATOR : [@velocity_x.abs, 0.001].max
  end

  def can_continue_jumping?
    time_since_beginning_of_jump_in_ms < CAN_JUMP_FOR_MS * jump_multiplicator
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
    if @y < -1000
      die!
    end
  end

  def die!
    @life = @life - 1
    if @life == 0
      @dead = true
    end
  end

  def dead?
    @dead
  end

  def normalSpeed!
    @max_speed = MAX_SPEED
  end

  def steroidsSpeed!
    @max_speed = MAX_STEROIDS_SPEED
  end

  def frottement
    jumping? ? FROTTEMENT_AIR : FROTTEMENT_TERRE
  end

  def inertia_x!
    @velocity_x /= frottement
  end

  def accelerate!(direction)
    @velocity_x += direction * ACCELERATION
    if @velocity_x.abs > @max_speed
      inertia_x!
    end
  end

  def draw(window)
    @window ||= window
    @jump_sound = Gosu::Sample.new(window, "media/jump.wav")
    window.draw_quad(
      window.scroll_x + x1, GameWindow::HEIGHT - y1, @color,
      window.scroll_x + x1, GameWindow::HEIGHT - y2, @color,
      window.scroll_x + x2, GameWindow::HEIGHT - y2, @color,
      window.scroll_x + x2, GameWindow::HEIGHT - y1, @color
    )
  end
end
