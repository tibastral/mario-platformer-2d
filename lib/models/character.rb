class Object
  def present?
    !nil?
  end
end

class Character
  attr_accessor :x, :y, :velocity_x, :velocity_y

  class_attribute :x_size, :y_size, :max_speed, :max_steroids_speed,
    :max_jump_multiplicator, :acceleration, :gravity, :jumping_velocity,
    :can_jump_for_ms, :x_init, :y_init, :max_jumps, :frottement_terre,
    :frottement_air, :window_half_size

  self.x_size = 32
  self.y_size = 96
  self.max_speed = 5
  self.max_steroids_speed = 10
  self.max_jump_multiplicator = 1.5
  self.acceleration = 0.4
  self.gravity = -1
  self.jumping_velocity = 15
  self.can_jump_for_ms = 50
  self.x_init = 100
  self.y_init = 10
  self.max_jumps = 4
  self.frottement_terre = 1.10
  self.frottement_air = 1.0005
  self.window_half_size = 128

  def initialize(map, options={})
    @map = map
    @x = options[:x] || x_init
    @y = options[:y] || y_init
    @previous_x = nil
    @previous_y = nil
    @velocity_x = 0.0
    @velocity_y = 0.0
    @nb_jumps = 0
    @gravity = gravity
    @life = options[:life]
    @dead = false
  end

  def x1; @x - x_size / 2; end
  def x2; @x + x_size / 2; end
  def y1; @y - y_size / 2; end
  def y2; @y + y_size / 2; end

  def previous_x1; @previous_x - x_size / 2; end
  def previous_x2; @previous_x + x_size / 2; end
  def previous_y1; @previous_y - y_size / 2; end
  def previous_y2; @previous_y + y_size / 2; end

  def scroll_x
    window_half_size - x1
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

  def moving?
    @velocity_x.abs > 0.3
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
      @y = object.y2 + y_size / 2
    end

      if side == :down
      @y = object.y1 - y_size / 2
    end

      if side == :right
      @x = object.x2 + x_size / 2
    end

      if side == :left
      @x = object.x1 - x_size / 2
    end
  end

  def time_since_beginning_of_jump_in_ms
    (Gosu::milliseconds - @begin_jump_at).to_i
  end

  def jump_multiplicator
    @velocity_x.abs > max_jump_multiplicator ? max_jump_multiplicator : [@velocity_x.abs, 0.001].max
  end

  def can_continue_jumping?
    time_since_beginning_of_jump_in_ms < can_jump_for_ms * jump_multiplicator
  end

  def jump!
    if @nb_jumps < max_jumps
      unless @begin_jump_at.present?
        @jump_sound.play
        @begin_jump_at = Gosu::milliseconds
      end
      if can_continue_jumping?
        @velocity_y = jumping_velocity
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

  def normal_speed!
    @max_speed = max_speed
  end

  def steroids_speed!
    @max_speed = max_steroids_speed
  end

  def frottement
    jumping? ? frottement_air : frottement_terre
  end

  def inertia_x!
    @velocity_x /= frottement
  end

  def accelerate!(direction)
    @velocity_x += direction * acceleration
    if @velocity_x.abs > @max_speed
      inertia_x!
    end
  end

  def draw(window)
    @window ||= window
  end

end
