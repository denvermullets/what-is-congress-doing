# parses data from 2 sources to create a Bill w/related data
module Congress
  class IngestBillMember < Service
    def initialize(sponsor:)
      @sponsor = sponsor
      @member = fetch_member
      @image_attribution = @member['depiction'] ? @member['depiction']['attribution'] : nil
      @image_url = @member['depiction'] ? @member['depiction']['imageUrl'] : nil
    end

    def call
      new_member = Member.create(
        bio_guide_id: @sponsor['bioguideId'], birth_year: @member['birthYear'],
        current_member: @member['currentMember'], direct_order_name: @member['directOrderName'],
        district: @member['district'], first_name: @member['firstName'],
        honorific_name: @member['honorificName'], inverted_order_name: @member['invertedOrderName'],
        last_name: @member['lastName'], middle_name: @member['middleName'],
        display_name: @sponsor['fullName'], official_website_url: @member['officialWebsiteUrl'],
        state: @member['state'], update_date: @member['updateDate'], party: @sponsor['party'],
        image_attribution: @image_attribution, image_url: @image_url
      )

      create_address(new_member)
      puts "created new member #{new_member.display_name}"

      new_member
    end

    private

    def create_address(new_member)
      Address.create(
        member_id: new_member.id,
        city: @member['addressInformation']['city'],
        district: @member['addressInformation']['district'],
        office_address: @member['addressInformation']['officeAddress'],
        phone_number: @member['addressInformation']['phoneNumber'],
        zip_code: @member['addressInformation']['zip_code']
      )
    end

    def fetch_member
      api = Congress::Api.new
      api.fetch_member(member_id: @sponsor['bioguideId'])['member']
    end
  end
end
