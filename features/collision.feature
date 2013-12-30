Feature: Collision
  In order to not be able to walk in a wall
  As a user
  I want to be stopped when I'm facing a wall

  Scenario: Mario walking
    Given a character on the ground
    Then the character should stay up the ground
    Given a wall
    When the character hits the wall
    Then he should be stopped by the wall
