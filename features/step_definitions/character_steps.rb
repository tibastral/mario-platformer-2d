Given(/^a character on the ground$/) do
  @map = GameMap.new
  @map.bricks << Brick.new(@map, x1: 0, x2: 1000, y1: 0, y2: 3)
  @character = Character.new(@map)
  @character.x = 500
  @character.y = 19
  @map.characters << @character
end

Then(/^the character should stay up the ground$/) do
  @character.move!
  # byebug
  @character.y1.should == 3
end

Given(/^a wall$/) do
  @map.bricks << Brick.new(@map, x1: 500, x2: 510, y1: 0, y2: 1000)
end

When(/^the character hits the wall$/) do
  @character.x = 498
  @character.velocity_x = 10
end

Then(/^he should be stopped by the wall$/) do
  @map.move!
  @character.x2.should == 499
  @character.y1.should == 17
end
