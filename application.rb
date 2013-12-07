require ::File.expand_path('config/boot')

Hasu.load "character.rb"
Hasu.load "brick.rb"
Hasu.load "game_window.rb"

GameWindow.run
