class Character
  attr_accessor :x, :y, :velocity_x, :velocity_y, :max_speed, :nb_jumps, :on_the_ground, :collision_handler

  class_attribute :x_size, :y_size, :lifes, :max_normal_speed, :max_steroids_speed, :max_crawling_speed,
    :max_jump_multiplicator, :acceleration, :gravity, :jumping_velocity,
    :can_jump_for_ms, :max_jumps, :frottement_terre, :size_multiplier,
    :frottement_air, :window_half_size

  self.max_jump_multiplicator = 1.5
  self.gravity = -1
  self.frottement_terre = 1.10
  self.frottement_air = 1.02

  def initialize(map, options={})
    @map = map
    @collision_handler ||= CollisionHandler.new(map, self)
    @x = options[:x]
    @y = options[:y]
    @previous_x = nil
    @previous_y = nil
    @velocity_x = 0.0
    @velocity_y = 0.0
    @nb_jumps = 0
    @gravity = gravity
    @dead = false
    @max_speed = max_normal_speed
    @crawling = false
    @on_the_ground = false
    @fast_falling = false
    self.window_half_size = GameWindow::WIDTH / 2
  end

  def x1; @x - (x_size * size_multiplier) / 2; end
  def x2; @x + (x_size * size_multiplier) / 2; end
  def y1; @y - (y_size * size_multiplier) / 2; end
  def y2; @y + (y_size * size_multiplier) / 2; end

  def previous_x1; @previous_x - (x_size * size_multiplier) / 2; end
  def previous_x2; @previous_x + (x_size * size_multiplier) / 2; end
  def previous_y1; @previous_y - (y_size * size_multiplier) / 2; end
  def previous_y2; @previous_y + (y_size * size_multiplier) / 2; end

  def scroll_x
    window_half_size - x1
  end

  def collision?(object)
    x2 > object.x1 &&
    x1 < object.x2 &&
    y1 < object.y2 &&
    y2 > object.y1
  end

  def move_x!
    @x += @velocity_x
  end

  def move!
    @previous_x = @x
    @previous_y = @y
    move_x!
    move_y!
    collision_handler.handle_collisions_with_bricks!
    collision_handler.handle_collisions_with_platforms!
  end

  def moving?
    @velocity_x.abs > 0.3
  end

  def can_move_out_of?(object, side)
    tmp_character = self.class.new(nil, x: @x, y: @y)
    tmp_character.move_out_of!(object, side)

    collision_detected = @map.bricks.reduce(false) { | c, brick |
      c || tmp_character.collision?(brick)
    }

    return !collision_detected
  end

  def move_out_of!(object, side)
    @y = object.y2 + (y_size * size_multiplier) / 2 if side == :up
    @y = object.y1 - (y_size * size_multiplier) / 2 if side == :down
    @x = object.x2 + (x_size * size_multiplier) / 2 if side == :right
    @x = object.x1 - (x_size * size_multiplier) / 2 if side == :left
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
    @on_the_ground = false
    stop_fast_falling!
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

  def fast_fall!
    if @previous_y && @y && @previous_y > @y
      @gravity *= 2.5 unless @fast_falling
      @fast_falling = true
    end
  end

  def stop_fast_falling!
    @gravity /= 2.5 if @fast_falling
    @fast_falling = false
  end

  def crawl!
    if @crawling == false
      @y -= 15
      self.y_size = 14
      self.acceleration /= 4
    end
    @crawling = true
  end

  def stop_crawling!
    if @crawling == true
      @y += 15
      self.y_size = 20
      self.acceleration *= 4
    end
    @crawling = false
  end

  def crawling?
    @crawling == true
  end

  def in_the_air?
    !@on_the_ground
  end

  def stop_jump!
    @begin_jump_at = nil
    @nb_jumps += 1
  end

  def move_y!
    @velocity_y += @gravity
    @y += @velocity_y
    die! if @y < -1000
  end

  def die!
    self.lifes -= 1
    @dead = true if self.lifes == 0
  end

  def dead?
    @dead
  end

  def on_steroids?
    @max_speed == max_steroids_speed
  end

  def normal_speed!
    @max_speed = max_normal_speed
  end

  def steroids_speed!
    @max_speed = max_steroids_speed
  end

  def crawl_speed!
    @max_speed = max_crawling_speed
  end

  def frottement
    in_the_air? ? frottement_air : frottement_terre
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

  def draw_sprite(sprite, window)
    sprite.draw(window.scroll_x + x1, GameWindow::HEIGHT - y2, 1, size_multiplier, size_multiplier)
  end
end
