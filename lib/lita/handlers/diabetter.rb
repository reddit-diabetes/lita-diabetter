module Lita
  module Handlers
    class Diabetter < Handler
      @@conversion_ratio = 18.0182
      @@lower = 25.0 # Lower limit for mmol/L - mg/dL cutoff
      @@upper = 50.0 # Upper limit for mmol/L - mg/dL cutoff

      route(/(?:^|_)(\d{1,3}|\d{1,2}\.\d+)(?:$|_)/, :convert, command: false, help: {
          '<number>' => 'Convert glucose between mass/molar concentration units.',
          '\_<number>\_' => 'Convert glucose between mass/molar concentration units inline. E.g "I started at \_125\_ today"'
      })

      route(/estimate a1c(?: from average)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimate_a1c, command: true, help: {
          'estimate a1c [from average] <glucose level>' => 'Estimates A1C based on average BG level'
      })
      route(/estimate average(?: from a1c)?\s+(\d{1,3}|\d{1,2}\.\d+)$/i, :estimate_average_from_a1c, command: true, help: {
          'estimate average [from a1c] <A1C>' => 'Estimates average blood glucose'
      })

      def convert(response)
        if response.message.body.match(URI.regexp(%w(http https))).nil?
          input = response.matches[0][0]
          Lita.logger.debug('Converting BG for input "' + input + '"')

          if input.to_f < @@lower
            response.reply("#{input} mmol/L is #{mmol_to_mgdl(input).to_s} mg/dL")
          elsif input.to_f >= @@lower && input.to_f < @@upper
            mmol = mgdl_to_mmol(input).to_s
            mgdl = mmol_to_mgdl(input).to_s

            result = '*I\'m not sure if you gave me mmol/L or mg/dL, so I\'ll give you both.*\n'
            result += "#{input} mg/dL is **#{mmol} mmol/L**\n"
            result += "#{input} mmol/L is **#{mgdl} mg/dL**"

            response.reply(result)
          else
            response.reply("#{input} mg/dL is #{mgdl_to_mmol(input).to_s} mmol/L")
          end
        end
      end

      def estimate_a1c(response)
        input = response.matches[0][0]
        Lita.logger.debug('Estimating a1c for input "' + input + '"')


        if input.to_f < @@lower
          mmol = input.to_f.round(1)
          mgdl = mmol_to_mgdl(mmol)

          type = 'mmol'
        elsif input.to_f >= @@lower && input.to_f < @@upper
          mmol = mgdl_to_mmol(input.to_f).round(1)
          mgdl = mmol_to_mgdl(input.to_f)

          type = 'unknown'
        else
          mgdl = input.to_i
          mmol = mgdl_to_mmol(mgdl)

          type = 'mgdl'
        end

        dcct = mgdl_to_dcct(mgdl)
        ifcc = dcct_to_ifcc(dcct).round(0).to_s
        dcct = dcct.round(1).to_s


        if type == 'unknown'
          reply = "*I'm not sure if you entered mmol/L or mg/dL, so I'll give you both*\n"
          reply += make_average_sentence('mmol', mmol, dcct, ifcc) + "\n"
          reply += make_average_sentence('mgdl', mgdl, dcct, ifcc)
        elsif type=='mmol'
          reply = make_average_sentence('mmol', mmol, dcct, ifcc)
        else
          reply = make_average_sentence('mgdl', mgdl, dcct, ifcc)
        end

        response.reply(reply)
      end

      def make_average_sentence(type, value, dcct, ifcc)
        if type == 'mmol'
          string = "An average of **#{value} mmol/L** is about "
        elsif type == 'mgdl'
          string = "An average of **#{value} mg/dL** is about "
        end

        string += "**#{dcct}%** (DCCT) or **#{ifcc} mmol/mol** (IFCC)"
      end

      def estimate_average_from_a1c(response)
        input = response.matches[0][0]
        Lita.logger.debug('Converting a1c to BG for input "' + input + '"')
        a1c = input.to_f
        dcct = 0
        ifcc = 0

        if input.index('.') == nil
          ifcc = a1c.round(0)
          dcct = ifcc_to_dcct(a1c).round(1)
        else
          dcct = a1c.round(1)
          ifcc = dcct_to_ifcc(a1c).round
        end

        mgdl = dcct_to_mgdl(dcct)

        reply = 'an A1C of ' + dcct.to_s + '% (DCCT) or '
        reply = reply + ifcc.to_s + ' mmol/mol (IFCC)'
        reply = reply + ' is about '
        reply = reply + mgdl.round.to_s + ' mg/dL or '
        reply = reply + mgdl_to_mmol(mgdl).round(1).to_s + ' mmol/L'
        response.reply(reply)
      end

      def mgdl_to_mmol(n)
        (n.to_i / @@conversion_ratio).round(1)
      end

      def mmol_to_mgdl(n)
        (n.to_f * @@conversion_ratio).round
      end

      def mgdl_to_dcct(n)
        ((n.to_i + 46.7) / 28.7)
      end

      def mgdl_to_ifcc(n)
        ((mgdl_to_dcct(n) - 2.15) * 10.929)
      end

      def dcct_to_ifcc(n)
        (n.to_f - 2.15) * 10.929
      end

      def ifcc_to_dcct(n)
        (n.to_f / 10.929) + 2.15
      end

      def dcct_to_mgdl(n)
        (n.to_f * 28.7) - 46.7
      end

      def ifcc_to_mgdl(n)
        dcct_to_mgdl((n / 10.929) + 2.5)
      end


    end
    Lita.register_handler(Diabetter)
  end
end
