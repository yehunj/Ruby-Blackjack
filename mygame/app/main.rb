#http://docs.dragonruby.org.s3-website-us-east-1.amazonaws.com/#---args-gtk-
require '/app/Deck.rb'
require '/app/Card.rb'
require '/app/Player.rb'
require '/app/from_now.rb'
require '/app/tick.rb'
def tick args
  $game.args = args
end
$gtk.reset
