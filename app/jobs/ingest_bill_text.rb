# ingest the individual bill based on type

class IngestBillText < ApplicationJob
  def perform(bill)
    if bill.nil?
      puts 'something went wrong, bill is nil'
      return
    end

    @bill = bill
    api = Congress::Api.new
    puts 'executing cooldown on bill text'
    sleep(3)
    puts 'resuming api calls'
    @text_links = api.fetch_bill_text(congress: @bill.congress, type: @bill.bill_type, number: @bill.number)

    fetch_url_data
  end

  def fetch_url_data
    return unless @text_links['textVersions'].present?

    sorted_data = @text_links['textVersions'].sort_by do |item|
      date = item['date'] ? DateTime.parse(item['date']) : nil
      [date.nil? ? 1 : 0, date]
    end
    find_text = sorted_data.last['formats'].find { |element| element['type'] == 'Formatted Text' }
    @bill.update(text_url: find_text['url'])
    @bill.save

    puts "updated bill ##{@bill.id}"
  end
end
