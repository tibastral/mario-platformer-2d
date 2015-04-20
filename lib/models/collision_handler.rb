class CollisionHandler
  attr_accessor :map, :character

  def initialize(map, character)
    @map = map
    @character = character
  end


  def collision?(object)
    character.x2 > object.x1 &&
    character.x1 < object.x2 &&
    character.y1 < object.y2 &&
    character.y2 > object.y1
  end

  def handle_collisions_with_platform!(platform, options={})
    came_from_up = character.previous_y1 >= platform.y2 if collision?(platform)
    if came_from_up
      character.nb_jumps = 0
      character.move_out_of!(platform, :up)
      character.velocity_y = 0
      character.on_the_ground = true
      character.stop_fast_falling!
    end
  end

  def handle_collision_with_brick!(brick, options={})
    if collision?(brick)
      came_from_up     = character.previous_y1 >= brick.y2
      came_from_down   = character.previous_y2 <= brick.y1
      came_from_right  = character.previous_x1 >= brick.x2
      came_from_left   = character.previous_x2 <= brick.x1

      rebound_speed = options[:rebound_speed] || 0

      if came_from_up
        character.nb_jumps = 0
        character.move_out_of!(brick, :up)
        character.velocity_y = 0
        character.on_the_ground = true
        character.stop_fast_falling!
      end

      if came_from_down
        character.move_out_of!(brick, :down)
        character.velocity_y = 0
      end

      if came_from_right
        character.move_out_of!(brick, :right)
        character.velocity_x = rebound_speed
      end

      if came_from_left
        character.move_out_of!(brick, :left)
        character.velocity_x = -rebound_speed
      end

    end
  end

  def handle_collision_with_enemy!(enemy, options={})
    if collision?(enemy)
      came_from_up     = character.previous_y1 >= enemy.previous_y2
      came_from_down   = character.previous_y2 <= enemy.previous_y1
      came_from_right  = character.previous_x1 >= enemy.previous_x2
      came_from_left   = character.previous_x2 <= enemy.previous_x1

      rebound_speed = options[:rebound_speed] || 0

      if came_from_up
        if character.can_move_out_of?(enemy, :up)
          character.move_out_of!(enemy, :up)
        elsif enemy.can_move_out_of?(character, :down)
          enemy.move_out_of!(character, :down)
        end
        character.velocity_y = 1
        character.nb_jumps = 0
        character.jump!
        character.stop_jump!
        enemy.die!
        character.stop_fast_falling!
      end

      if came_from_down
        if character.can_move_out_of?(enemy, :down)
          character.move_out_of!(enemy, :down)
        elsif enemy.can_move_out_of?(character, :up)
          enemy.move_out_of!(character, :up)
          enemy.velocity_y = rebound_speed
        end
        character.velocity_y = 0
        character.die!
      end

      if came_from_right
        if character.can_move_out_of?(enemy, :right)
          character.move_out_of!(enemy, :right)
        elsif enemy.can_move_out_of?(character, :left)
          enemy.move_out_of!(character, :left)
          enemy.velocity_x = -rebound_speed
        end
        character.velocity_x = rebound_speed
        character.die!
      end

      if came_from_left
        if character.can_move_out_of?(enemy, :left)
          character.move_out_of!(enemy, :left)
        elsif enemy.can_move_out_of?(character, :right)
          enemy.move_out_of!(character, :right)
          enemy.velocity_x = rebound_speed
        end
        character.velocity_x = -rebound_speed
        character.die!
      end
    end
  end

  def handle_collisions_with_platforms!
    @map.platforms.each do |platform|
      handle_collisions_with_platform!(platform)
    end
  end

  def handle_collisions_with_bricks!
    @map.bricks.each do |brick|
      handle_collision_with_brick!(brick)
    end
  end

  def handle_collisions_with_enemies!
    @map.enemies.each do |enemy|
      handle_collision_with_enemy!(enemy, rebound_speed: 10)
    end
  end

end
