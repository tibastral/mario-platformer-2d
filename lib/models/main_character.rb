class MainCharacter < Character

  self.x_size = 7
  self.y_size = 20
  self.size_multiplier = 5
  self.max_steroids_speed = 10
  self.max_normal_speed = 5
  self.lifes = 3
  self.acceleration = 0.4

  def initialize(map, options)
    super(map, options)
    @color ||= Gosu::Color::RED
  end

  def handle_collisions_with_enemies!
    @map.enemies.each do |enemy|
      handle_collision_with_enemy!(enemy, rebound_speed: 10)
    end
  end

  def handle_collision_with_enemy!(enemy, options={})
    if collision?(enemy)
      came_from_up     = previous_y1 >= enemy.previous_y2
      came_from_down   = previous_y2 <= enemy.previous_y1
      came_from_right  = previous_x1 >= enemy.previous_x2
      came_from_left   = previous_x2 <= enemy.previous_x1

      rebound_speed = options[:rebound_speed] || 0

      if came_from_up
        if can_move_out_of?(enemy, :up)
          move_out_of!(enemy, :up)
        elsif enemy.can_move_out_of?(self, :down)
          enemy.move_out_of!(self, :down)
        end
        @velocity_y = 0
        @nb_jumps = 0
        jump!
        stop_jump!
        enemy.die!
      end

      if came_from_down
        if can_move_out_of?(enemy, :down)
          move_out_of!(enemy, :down)
        elsif enemy.can_move_out_of?(self, :up)
          enemy.move_out_of!(self, :up)
          enemy.velocity_y = rebound_speed
        end
        @velocity_y = 0
        die!
      end

      if came_from_right
        if can_move_out_of?(enemy, :right)
          move_out_of!(enemy, :right)
        elsif enemy.can_move_out_of?(self, :left)
          enemy.move_out_of!(self, :left)
          enemy.velocity_x = -rebound_speed
        end
        @velocity_x = rebound_speed
        die!
      end

      if came_from_left
        if can_move_out_of?(enemy, :left)
          move_out_of!(enemy, :left)
        elsif enemy.can_move_out_of?(self, :right)
          enemy.move_out_of!(self, :right)
          enemy.velocity_x = rebound_speed
        end
        @velocity_x = -rebound_speed
        die!
      end

    end
  end

  def move!
    super
    handle_collisions_with_enemies!
    draw_string(@life)
  end

  def die!
    super
    @map.reset if @dead
  end

  def draw(window)
    super(window)
    @jump_sound ||= Gosu::Sample.new(window, "media/jump.wav")
    @right_tiles ||= Gosu::Image.load_tiles(window, 'media/mario_right.png', 7, 20, true)
    @left_tiles ||= Gosu::Image.load_tiles(window, 'media/mario_left.png', 7, 20, true)
    @jump_tiles ||= Gosu::Image.load_tiles(window, 'media/mario_jump.png', 7, 20, true)
    @down_tiles ||= Gosu::Image.load_tiles(window, 'media/mario_down.png', 7, 14, true)

    @sprites ||= {
      walking: {
        right: @right_tiles,
        left: @left_tiles
      },
      standing: {
        right: @right_tiles[3],
        left: @left_tiles[3],
      },
      jumping: {
        right: @jump_tiles[0],
        left: @jump_tiles[1]
      },
      crawling: {
        right: @down_tiles[1],
        left: @down_tiles[0]
      }
    }

    @facing ||= :right

    @facing = right_or_left? if moving? && !jumping?

    if crawling?
      draw_crawling_animation(window)
    elsif jumping?
      draw_jumping_animation(window)
    elsif moving?
      draw_walking_animation(window)
    else
      draw_sprite(@sprites[:standing][@facing], window)
    end

    draw_string('Life: ' + @life.to_s)
  end

  def draw_jumping_animation(window)
    draw_sprite(@sprites[:jumping][@facing], window)
  end

  def draw_walking_animation(window)
    draw_sprite(@sprites[:walking][@facing][(((Time.now.to_f % 1) * 10).to_i) / 3], window)
  end

  def draw_crawling_animation(window)
    draw_sprite(@sprites[:crawling][@facing], window)
  end

  def draw_string(str)
    @map.window.font.draw(str, 10, 10, -10000)
  end


  def right_or_left?
    if @previous_x < @x
      :right
    else
      :left
    end
  end

end
