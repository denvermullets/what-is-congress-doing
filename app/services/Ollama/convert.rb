# send off previous AI response to put it into a json schema
module Ollama
  class Convert < Service
    def initialize(bill:)
      @url = 'http://localhost:11434/api/chat'
      @bill = bill
      @prompt = prompt
    end

    def call
      puts "Converting bill response to JSON - #{@bill.title}"
      uri = URI(@url)
      request = send_to_ollama(uri:)
      final_response = process_result(uri:, request:)

      @bill.bill_text.update(ai_json: final_response.to_json)
    end

    private

    def process_result(uri:, request:)
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end

      parsed_response = JSON.parse(response.body)

      parsed_response.dig('message', 'content') || ''
    end

    # rubocop:disable Metrics/MethodLength
    def send_to_ollama(uri:)
      request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

      request.body = {
        model: 'qwen2.5-coder:32b',
        messages: [{ role: 'assistant', content: @prompt }],
        stream: false,
        # format: {
        #   type: 'object',
        #   properties: {
        #     rating: { type: 'number' },
        #     summary: { type: 'string' },
        #     pros: { type: 'array', items: { type: 'string' } },
        #     cons: { type: 'array', items: { type: 'string' } },
        #     facism: { type: 'array', items: { type: 'string' } },
        #     wealth: { type: 'array', items: { type: 'string' } }
        #   },
        #   required: %w[rating summary pros cons facism wealth]
        # }
        properties: {
          bill_summary: {
            type: 'object', properties: { title: { type: 'string' }, description: { type: 'string' } },
            required: %w[title description]
          },
          analysis: {
            type: 'object',
            properties: {
              perspective: { type: 'string' },
              pros: {
                type: 'array',
                items: { type: 'object', properties: { title: { type: 'string' }, description: { type: 'string' } },
                         required: %w[title description] }
              },
              cons: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: { title: { type: 'string' }, description: { type: 'string' } },
                  required: %w[title description]
                }
              },
              batshit_crazy_rating: {
                type: 'object',
                properties: { score: { type: 'integer', minimum: 1, maximum: 10 }, justification: { type: 'string' } },
                required: %w[score justification]
              }
            },
            required: %w[perspective pros cons batshit_crazy_rating]
          }
        },
        required: %w[bill_summary analysis]

      }.to_json

      request
    end
    # rubocop:enable Metrics/MethodLength

    def prompt
      # base_prompt = <<~PROMPT
      #   You must return only JSON. Do not include explanations. Do not trim down the data.
      #   DO NOT CHANGE THE DATA. you are purely meant to parse.
      #   all i need is for you to arrange the data in the given schema.
      #   the bullet points in the Pros section goes in the pros array.
      #   the bullet points in the Cons section goes in the cons array.
      #   the bullet points in the Facism sounding section goes in the facism array.
      #   the bullet points in the Wealth sounding section goes in the wealth array.
      #   do not confuse the rating - it is 1 thru 10 only.
      #   Here is the data:
      # PROMPT
      base_prompt = <<~PROMPT
        Instruction: Take the following raw text analysis of a bill and convert it into JSON.
        Extract relevant information accurately while preserving meaning.

        Ensure that:
        - The **bill title and description** are placed under bill_summary.
        - The **perspective** is correctly captured from the text.
        - The **pros** and **cons** are correctly categorized, with each having a **title** and **description**.
        - The **Batshit Crazy Rating** is extracted as an integer and includes the justification.
        - The output is strictly in valid JSON format. EXTREMELY IMPORTANT
      PROMPT

      puts "bill result is nil??????????????? #{bill.bill_text.result.nil?}"
      bill_info = @bill.bill_text.result
      "#{base_prompt.strip}\n\n#{bill_info.strip}"
    end
  end
end
