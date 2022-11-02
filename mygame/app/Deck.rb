require '/app/Card.rb'
class Deck
    # Intialize the deck
    $cards = []

    def initialize
        @suits = ['Hearts', 'Diamonds', 'Spades', 'Clubs']
        @faces = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace']
        @suits.each do |suit|
            @faces.each do |face|
                $cards << Card.new(suit, face)
            end
        end
    end

    # Shuffle the deck
    def shuffle
        $cards.shuffle!
    end

    # Deal a card
    def deal
        $cards.pop
    end

    

end