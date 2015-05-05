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

  def ground_collision_behavior(object)
    character.nb_jumps = 0
    character.move_out_of!(object, :up)
    character.velocity_y = 0
    character.on_the_ground = true
    character.stop_fast_falling!
  end

  def head_collision_behavior(object)
    character.move_out_of!(object, :down)
    character.velocity_y = 0
  end

  def lateral_collision_behavior(object, direction, rebound_speed)
    character.move_out_of!(object, direction)
    character.velocity_x = rebound_speed
  end

  def handle_collisions_with_platform!(platform)
    ground_collision_behavior(platform) if character.came_from_up?(platform)
  end

  def handle_collision_with_brick!(brick)
    ground_collision_behavior(brick) if character.came_from_up?(brick)
    head_collision_behavior(brick) if character.came_from_down?(brick)
    lateral_collision_behavior(brick, :left, 0) if character.came_from_right?(brick)
    lateral_collision_behavior(brick, :right, 0) if character.came_from_left?(brick)
  end

  def handle_collision_with_enemy!(enemy, options={})
    rebound_speed = options[:rebound_speed] || 0

    came_from_up     = character.previous_y1 >= enemy.previous_y2
    came_from_down   = character.previous_y2 <= enemy.previous_y1
    came_from_right  = character.previous_x1 >= enemy.previous_x2
    came_from_left   = character.previous_x2 <= enemy.previous_x1

    if came_from_up
      if character.can_move_out_of?(enemy, :up)
        character.move_out_of!(enemy, :up)
      elsif enemy.can_move_out_of?(character, :down)
        enemy.move_out_of!(character, :down)
      end
      ground_collision_behavior(enemy)
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

  def handle_collisions_with_platforms!
    @map.platforms.each do |platform|
      handle_collisions_with_platform!(platform) if collision?(platform)
    end
  end

  def handle_collisions_with_bricks!
    @map.bricks.each do |brick|
      handle_collision_with_brick!(brick) if collision?(brick)
    end
  end

  def handle_collisions_with_enemies!
    @map.enemies.each do |enemy|
      handle_collision_with_enemy!(enemy, rebound_speed: 10) if collision?(enemy)
    end
  end

end
