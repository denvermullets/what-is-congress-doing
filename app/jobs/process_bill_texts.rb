class ProcessBillTexts < ApplicationJob
  def perform
    bills = Bill.where.not(text_url: nil)
    bills.map do |bill|
      next unless bill.bill_text.nil?

      api = Congress::Api.new
      text = api.fetch_text(url: bill.text_url)
      BillText.create(bill:, bill_text: text)
      puts "obtained text for #{bill.congress}/#{bill.number}"
    end
  end
end
