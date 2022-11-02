  require '/app/Deck.rb'
  require '/app/Card.rb'
  require '/app/from_now.rb'
  def tick args
    FromNow.tick
    args.state.scroll_location  ||= 0
    args.state.textbox.messages ||= []
    args.state.textbox.scroll   ||= 0
    args.outputs[:textbox].background_color = [0, 0, 0, 150]
    setup args if args.tick_count == 0
    if args.state.scene == :main_menu
      render_main_menu args
    elsif args.state.scene == :game
      render_game args
    end
  end

  def setup args  
    args.state.scene = :main_menu
  end
  
  def render_main_menu args 
    args.outputs.labels  << [640, 600, 'Welcome to Ruby Blackjack!', 5, 1]
    args.outputs.sprites << [480, 250, 320, 320, 'icon.png']
    args.outputs.labels  << [640, 230, 'Press Space to Play', 5, 1]
    
    
    if args.inputs.keyboard.key_down.space
      start_game args
    end
  end

  def start_game args
    args.state.scene = :game
    args.state.deck = Deck.new
    args.state.deck.shuffle
    args.state.player = Player.new
    args.state.dealer = Player.new
    args.state.player.hand << args.state.deck.deal
    args.state.player.hand << args.state.deck.deal
    args.state.dealer.hand << args.state.deck.deal
    queue_message args, "Your current hand " + args.state.player.hand.to_s.inspect + "\nTotal:" + args.state.player.handtotal.to_s
    queue_message args, "Dealers hand " + args.state.dealer.hand.to_s.inspect + "\nTotal:" + args.state.dealer.handtotal.to_s
  end 

  def render_game args
    args.state.dealerscore ||= 0
    args.state.playerscore ||= 0
    args.outputs.sounds << 'sounds/Kevin-MacLeod-Cipher.ogg'
    args.state.buttons ||= [
      create_button(args, id: :Hit, row: 11, col: 12, text: "Hit"),
      create_button(args, id: :Stand, row: 11, col: 14, text: "Stand")
    ]
    args.outputs.primitives << args.state.buttons.map do |b|
      b.primitives
    end

    render_messages args
    if args.state.player.handtotal > 21
      queue_message args, "You busted!"
      args.state.dealerscore += 1
      start_game args
    end

    if args.state.player.handtotal == 21
      queue_message args, "You got Blackjack!"
      args.state.playerscore += 1
      start_game args
    end

    sprite_parser args, args.state.player.hand, 400, 200
    sprite_parser args, args.state.dealer.hand, 400, 450
    special_sprite args, "Stack", 300, 450    

    args.outputs.labels << [445, 625, "Dealer", 5, 1]
    args.outputs.labels << [100, 100, "Score: " + args.state.playerscore.to_s + " - " + args.state.dealerscore.to_s, 5, 1]
    if args.inputs.mouse.click && args.state.player.handtotal < 21 && args.state.dealer.handtotal < 21
      button = args.state.buttons.find do |b|
        args.inputs.mouse.intersect_rect? b
      end
  
      # update the center label text based on button clicked
      case button.id
      when :Hit
        args.outputs.labels << [640, 600, 'Hit!', 5, 1]
        card = args.state.deck.deal
        args.state.player.hand << card
        queue_message args, 'You drew a ' + card.to_s
        queue_message args, "Your current hand " + args.state.player.hand.to_s.inspect + "\nTotal:" + args.state.player.handtotal.to_s
      when :Stand
        # remove the hidden card
        queue_message args, "You've standed"
        args.state.dealer.hand << args.state.deck.deal
        queue_message args, "Dealer reveals his hand " + args.state.dealer.hand.to_s.inspect + "\nTotal:" + args.state.dealer.handtotal.to_s

        while args.state.dealer.handtotal < 17
          card = args.state.deck.deal
          args.state.dealer.hand << card
          queue_message args, 'Dealer drew a ' + card.to_s
          queue_message args, "Dealers hand " + args.state.dealer.hand.to_s.inspect + "\nTotal:" + args.state.dealer.handtotal.to_s
        end

        if args.state.dealer.handtotal > 21
          queue_message args, "Dealer busted!"
          queue_message args, "You win!"
          args.state.playerscore += 1
        elsif args.state.dealer.handtotal > args.state.player.handtotal
          queue_message args, "Dealer wins!"
          args.state.dealerscore += 1
        elsif args.state.dealer.handtotal < args.state.player.handtotal
          queue_message args, "You win!"
          args.state.playerscore += 1
        elsif args.state.dealer.handtotal == args.state.player.handtotal
          queue_message args, "It's a tie!"
        end

        1.seconds.from_now do
          start_game args
        end
      end
    end
  end

  def create_button args, id:, row:, col:, text:;
    # args.layout.rect(row:, col:, w:, h:) is method that will
    # return a rectangle inside of a grid with 12 rows and 24 columns
    rect = args.layout.rect row: row, col: col, w: 2, h: 1
  
    # get senter of rect for label
    center = args.geometry.rect_center_point rect
  
    {
      id: id,
      x: rect.x,
      y: rect.y,
      w: rect.w,
      h: rect.h,
      primitives: [
        {
          x: rect.x,
          y: rect.y,
          w: rect.w,
          h: rect.h,
          primitive_marker: :border
        },
        {
          x: center.x,
          y: center.y,
          text: text,
          size_enum: -1,
          alignment_enum: 1,
          vertical_alignment_enum: 1,
          primitive_marker: :label
        }
      ]
    }
  end

  def queue_message args, msg
    args.state.textbox.messages.concat msg.wrapped_lines 50
  end

  def render_messages args
    args.outputs[:textbox].w = 400
    args.outputs[:textbox].h = 720
  
    args.outputs[:textbox].labels << args.state.textbox.messages.each_with_index.map do |s, idx|
      {
        x: 0,
        y: 20 * (args.state.textbox.messages.size - idx) + args.state.textbox.scroll * 20,
        text: s,
        size_enum: -3,
        alignment_enum: 0,
        r: 0, g: 255, b: 0, a: 255
      }
    end
  
    args.outputs[:textbox].borders << [0, 0, args.outputs[:textbox].w, 720]
  
    args.state.textbox.scroll += args.inputs.mouse.wheel.y unless args.inputs.mouse.wheel.nil?
  
    if args.state.scroll_location > 0
      args.state.textbox.scroll = 0
      args.state.scroll_location = 0
    end
  
    args.outputs.sprites << [900, 0, args.outputs[:textbox].w, 720, :textbox]
  end

  
  def sprite_parser args, hand, x, y
    # Bottom left = 0
    sprite_index = {
    "King": {
      source_x: 0,
      source_y: 0,
      source_w: 88,
      source_h: 124
    },
    "Queen": {
      source_x: 88,
      source_y: 0,
      source_w: 88,
      source_h: 124
    },
    "Jack": {
      source_x: 176,
      source_y: 0,
      source_w: 88,
      source_h: 124
    },
    "6": {
      source_x: 0,
      source_y: 124,
      source_w: 88,
      source_h: 124
    },
    "7": {
      source_x: 88,
      source_y: 124,
      source_w: 88,
      source_h: 124
    },
    "8": {
      source_x: 176,
      source_y: 124,
      source_w: 88,
      source_h: 124
    },
    "9": {
      source_x: 264,
      source_y: 124,
      source_w: 88,
      source_h: 124
    },
    "10": {
      source_x: 352,
      source_y: 124,
      source_w: 88,
      source_h: 124
    },
    "Ace": {
      source_x: 0,
      source_y: 248,
      source_w: 88,
      source_h: 124
    },
    "2": {
      source_x: 88,
      source_y: 248,
      source_w: 88,
      source_h: 124
    },
    "3": {
      source_x: 176,
      source_y: 248,
      source_w: 88,
      source_h: 124
    },
    "4": {
      source_x: 264,
      source_y: 248,
      source_w: 88,
      source_h: 124
    },
    "5": {
      source_x: 352,
      source_y: 248,
      source_w: 88,
      source_h: 124
    },      
  }
    # Parse each card to their respective suit and face.
    hand.each do |card|
      if card.suit == 'Hearts'
        args.outputs.sprites << {x:x, y:y, w:88, h:124, path: 'sprites/Cards/Hearts.png'}.merge(sprite_index[card.face.to_sym])
        x += 30
      elsif card.suit == 'Diamonds'
        args.outputs.sprites << {x:x, y:y, w:88, h:124, path: 'sprites/Cards/Diamonds.png'}.merge(sprite_index[card.face.to_sym])
        x += 30
      elsif card.suit == 'Spades'
        args.outputs.sprites << {x:x, y:y, w:88, h:124, path: 'sprites/Cards/Spades.png'}.merge(sprite_index[card.face.to_sym])
        x += 30
      elsif card.suit == 'Clubs'
        args.outputs.sprites << {x:x, y:y, w:88, h:124, path: 'sprites/Cards/Clubs.png'}.merge(sprite_index[card.face.to_sym])
        x += 30
      end
    end
  end

  def special_sprite args, type, x, y
    sprite_index = {
      "Hidden": {
        source_x: 88,
        source_y: 0,
        source_w: 88,
        source_h: 124
      },
      "Stack": {
        source_x: 0,
        source_y: 0,
        source_w: 88,
        source_h: 140
      },
    }

    if type == 'Hidden'
      args.outputs.sprites << {x:x, y:y, w:88, h:124, path: 'sprites/Cards/Hidden.png'}.merge(sprite_index[type.to_sym])
    elsif type == 'Stack'
      args.outputs.sprites << {x:x, y:y, w:88, h:140, path: 'sprites/Cards/Stack.png'}.merge(sprite_index[type.to_sym])
    end
  end
    
