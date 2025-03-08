# kick off request to AI to process
module Ollama
  class Generate < Service
    def initialize(bill:)
      @url = 'http://localhost:11434/api/generate'
      @bill = bill
      @prompt = prompt
    end

    def call
      puts "Starting with Bill - #{@bill.title}"
      uri = URI(@url)
      request = build_request(uri:)
      final_response = send_to_ollama(uri:, request:)

      if @bill.bill_text.nil?
        BillText.create(bill: @bill, result: final_response)
      else
        @bill.bill_text.update(result: final_response)
      end

      # structured outputs just don't seem to work as well as they should
      # will need to revisit this idea as time goes on
      # puts 'kicking off conversion'
      # Ollama::Convert.call(bill: @bill)
    end

    private

    def send_to_ollama(uri:, request:)
      final_response = ''

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request) do |response|
          response.body.each_line do |line|
            parsed_line = begin
              JSON.parse(line)
            rescue StandardError
              nil
            end
            next unless parsed_line

            chunk = parsed_line['response']
            # output to console
            print chunk
            final_response << chunk if chunk
          end
        end
      end

      final_response.gsub!(%r{<think>.*?</think>}m, '')
    end

    def build_request(uri:)
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

      request.body = {
        model: 'huihui_ai/deepseek-r1-abliterated:70b',
        prompt: @prompt,
        # stream: false,
        options: {
          num_ctx: 4096
        }

      }.to_json

      request
    end

    def prompt
      # base_prompt = <<~PROMPT
      #   I need you to summarize this bill and outline the 'pros' and 'cons' bulleted list.
      #   You must view this from the lens of a leftist progressive point of view. also split out
      #   potential abuse by a facsist leaning president into a bulleted list called 'facism' (no other title).
      #   also highlight anything that enables billionaires or wealth accumulation going to 1% of the population
      #   into a bulleted list called 'wealth' (no other title).
      #   only give 1 summary.

      #   it is extremely important that you follow these instructions.

      #   At the end of this, you need to give a rating on a scale of 1-10 on how crazy
      #   and/or alarming this is, where 1 is not crazy and 10 is absolutely crazy and/or alarming.
      # PROMPT
      base_prompt = <<~PROMPT
        I need you to summarize this bill and outline the pros and cons.
        You must view this from the lens of a leftist progressive point of view. highlight any
        potential abuse by a facsist leaning president and also highlight anything that enables billionaires
        or wealth accumulation going to 1% of the population.

        At the end of this, you need to give a rating on a scale of 1-10 on how batshit crazy this is,
        where 1 is not crazy and 10 is absolutely batshit crazy.
      PROMPT

      bill_info = @bill.bill_text&.bill_text || @bill.title
      "#{base_prompt.strip}\n\n#{bill_info.strip}"
    end
  end
end
