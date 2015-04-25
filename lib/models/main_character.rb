class MainCharacter < Character

  ACTIONS_WITH_ANIMATION = [:walking]

  self.current_x_size = 35
  self.current_y_size = 100
  self.x_normal_size = 35
  self.y_normal_size = 100
  self.y_crawl_size = 70
  self.size_multiplier = 1
  self.max_steroids_speed = 10
  self.max_normal_speed = 5
  self.max_crawling_speed = 0.3
  self.lifes = 3
  self.acceleration = 0.4
  self.max_jumps = 2
  self.jumping_velocity = 17
  self.can_jump_for_ms = 50
  self.crawling_speed_ratio = 4

  def initialize(map, options)
    super(map, options)
  end

  def move!
    super
    collision_handler.handle_collisions_with_enemies!
    draw_string(self.lifes.to_s)
  end

  def die!
    super
    @map.reset if @dead
  end

  def generate_sprites(window)
    right_tiles = Gosu::Image.load_tiles(window, 'media/main_character_right.png', current_x_size, current_y_size, false)
    left_tiles = Gosu::Image.load_tiles(window, 'media/main_character_left.png', current_x_size, current_y_size, true)
    jump_tiles = Gosu::Image.load_tiles(window, 'media/main_character_jump.png', current_x_size, current_y_size, true)
    down_tiles = Gosu::Image.load_tiles(window, 'media/main_character_down.png', current_x_size, y_crawl_size, true)
    {
      walking: { right: right_tiles, left: left_tiles },
      standing: { right: right_tiles[3], left: left_tiles[3] },
      jumping: { right: jump_tiles[0], left: jump_tiles[1] },
      crawling: { right: down_tiles[1], left: down_tiles[0] }
    }
  end

  def draw(window)
    super(window)
    @jump_sound ||= Gosu::Sample.new(window, 'media/jump.wav')
    @sprites ||= generate_sprites(window)
    @facing ||= :right
    @facing = right_or_left? if moving? && !in_the_air?

    case
    when crawling?
      draw_action(window, :crawling)
    when in_the_air?
      draw_action(window, :jumping)
    when moving?
      draw_action(window, :walking)
    else
      draw_action(window, :standing)
    end

    draw_string('Life: ' + self.lifes.to_s)
  end

  def draw_action(window, action)
    if ACTIONS_WITH_ANIMATION.include?(action)
      walking_speed = on_steroids? ? 2 : 1
      draw_sprite(@sprites[action][@facing][animation_time(walking_speed)], window)
    else
      draw_sprite(@sprites[action][@facing], window)
    end
  end

  def draw_string(str)
    @map.window.font.draw(str, 10, 10, 10000)
  end

  def animation_time(ratio = 1)
    time = (Time.now.to_f % 1 * 10) % (10 / ratio)
    case
    when time < (2.5 / ratio)
      0
    when time >= (2.5 / ratio) && time < (5 / ratio)
      1
    when time >= (5 / ratio) && time < (7.5 / ratio)
      2
    when time >= (7.5 / ratio)
      3
    end
  end

  def right_or_left?
    @previous_x < @x ? :right : :left
  end

end
