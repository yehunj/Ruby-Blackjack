require '/app/Card.rb'
class Player
    attr_accessor :hand

    def initialize()
        @hand = []
    end

    def addCard(card)
        @hand.push(card)
    end

    def to_s
        return "#{@hand}"
    end

    def handtotal
        total = 0
        @hand.each do |card|
            total += card.face_to_int
        end
        return total
    end

end
