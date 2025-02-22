# parses data from 2 sources to create a Bill w/related data
module Congress
  class IngestBillData < Service
    def initialize(bill:, json_response:)
      @bill = bill
      @json = json_response
    end

    def call
      new_bill = create_bill

      # === logging
      bill_info = "#{new_bill.origin_chamber_code} - #{new_bill.number}"
      puts "created bill #{bill_info}"
      # === logging

      create_latest_action(new_bill)

      # === logging
      puts "created latest action #{bill_info}"
      # === logging

      Congress::IngestBillSponsors.call(bill: new_bill, sponsors: @json['bill']['sponsors'], primary: true)

      if cosponsor_present?
        api = Congress::Api.new
        cosponsors = api.fetch_cosponsors(
          congress: new_bill.congress, type: new_bill.bill_type, number: new_bill.number
        )

        Congress::IngestBillSponsors.call(bill: new_bill, sponsors: cosponsors['cosponsors'], primary: false)
      end

      new_bill
    end

    private

    def create_bill
      Bill.create!(
        congress: @bill['congress'],
        number: @bill['number'],
        origin_chamber: @bill['originChamber'],
        origin_chamber_code: @bill['originChamberCode'],
        title: @bill['title'],
        constitutional_authority_statement_text: @json['bill']['constitutionalAuthorityStatementText'],
        bill_type: @bill['type'],
        update_date: @bill['updateDate'],
        update_date_including_text: @bill['updateDateIncludingText'],
        introduced_date: @json['bill']['introducedDate']
      )
    end

    def create_latest_action(new_bill)
      LatestAction.create(
        bill_id: new_bill.id,
        action_date: @bill['latestAction']['actionDate'],
        text: @bill['latestAction']['text']
      )
    end

    def cosponsor_present?
      @json['bill']['cosponsors'].present? && @json['bill']['cosponsors']['count'].positive?
    end
  end
end
