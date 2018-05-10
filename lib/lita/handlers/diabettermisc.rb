module Lita
  module Handlers
    class DiabetterMisc < Handler

      route(/^-diabot.*$/i, :deprecated, command: false)

      route(/^diabetes y$/i, :diabetesy, command: false, restrict_to: :diabot_meme)

      route(/^(?:diab((etes)|(ot)) )?plz$/i, :plz, command: false, restrict_to: :diabot_meme)

      route(/ feel it /i, :feelit, command: false)

      def deprecated(response)
        response.reply('The -diabot prefix is deprecated. See `diabot help` for more info')
      end

      # here be memes

      def diabetesy(response)
        response.reply('Because diabetes r hard')
      end

      def plz(response)
        response.reply('K')
      end

      def feelit(response)
        chance = 20
        rolled = rand(1..100)
        if rolled < chance
          response.reply('https://youtu.be/fxn2A1oYqvs')
        end
      end

      # The memes have ended

    end
    Lita.register_handler(DiabetterMisc)
  end
end
