require ::File.expand_path('config/boot')

Hasu.load "lib/models/character.rb"
Hasu.load "lib/models/enemy.rb"
Hasu.load "lib/models/main_character.rb"
Hasu.load "lib/models/brick.rb"
Hasu.load "lib/models/platform.rb"
Hasu.load "lib/models/game_map.rb"
Hasu.load "lib/game_window.rb"

GameWindow.run
