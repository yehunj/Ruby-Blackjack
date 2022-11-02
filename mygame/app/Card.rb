class Card
    #Creates a new card
    attr_accessor :suit, :face
    def initialize(suit, face)
        @suit = suit
        @face = face
    end

    #Returns the card as a string
    def to_s
        return "#{@face} of #{@suit}"   
    end

    def face_to_int
        if @face == "Ace"
            return 11
        elsif @face == "Jack" || @face == "Queen" || @face == "King"
            return 10
        else
            return @face.to_i
        end
    end

    def inspect
        return "#{@face} of #{@suit}"
    end

end