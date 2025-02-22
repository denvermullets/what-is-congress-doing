# ingests Sponsors and associates with a Bill
# Primary would be true is they're a main sponsor, false if they're a cosponsor

module Congress
  class IngestBillSponsors < Service
    def initialize(bill:, sponsors:, primary:)
      @bill = bill
      @sponsors = sponsors
      @primary = primary
    end

    def call
      # verify member exists, create if not
      # then create join record for bill and sponsor
      @sponsors.each do |sponsor|
        member = Member.find_by(bio_guide_id: sponsor['bioguideId'])
        member = Congress::IngestBillMember.call(sponsor:) if member.nil?
        @primary == true ? BillSponsor.create(bill: @bill, member:) : BillCoSponsor.create(bill: @bill, member:)

        # === logging
        member_info = "#{@bill.id}, #{member.id}"
        puts @primary ? "created BillSponsor #{member_info}" : "created BillCoSponsor #{member_info}"
        # === logging
      end
    end
  end
end
