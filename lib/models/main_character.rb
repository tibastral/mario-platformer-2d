
class MainCharacter < Character

  def initialize(map, options)
    super(map, options)
    @max_speed = MAX_SPEED
    @color = Gosu::Color::RED
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
    if @dead 
      @map.reset
    end
  end

  def draw(window)
    super(window)
    draw_string("Life: " + @life.to_s)
  end
    
  def draw_string(str)
    @map.window.font.draw(str, 10, 10, -10000)
  end
    
end
