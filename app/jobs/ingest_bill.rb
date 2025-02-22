# ingest the individual bill based on type

class IngestBill < ApplicationJob
  def perform(bill)
    @api_key = fetch_api_key
    json_response = fetch_data(bill)

    new_bill = process_data(json_response, bill)

    puts "kicking off new bill #{new_bill.id}"
    IngestBillText.perform_later(new_bill)
  rescue StandardError => e
    log_and_raise(e)
  end

  private

  def fetch_data(bill)
    congress = bill['congress']
    type = bill['type']
    number = bill['number']

    url = "https://api.congress.gov/v3/bill/#{congress}/#{type}/#{number}?format=json"
    response = HTTParty.get(url, headers: { 'X-Api-Key' => @api_key })

    raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

    response.parsed_response
  end

  def process_data(json_response, bill)
    new_bill = Bill.create!(
      congress: bill['congress'],
      number: bill['number'],
      origin_chamber: bill['originChamber'],
      origin_chamber_code: bill['originChamberCode'],
      title: bill['title'],
      constitutional_authority_statement_text: json_response['bill']['constitutionalAuthorityStatementText'],
      bill_type: bill['type'],
      update_date: bill['updateDate'],
      update_date_including_text: bill['updateDateIncludingText'],
      introduced_date: json_response['bill']['introducedDate']
    )

    bill_info = "#{new_bill.origin_chamber_code} - #{new_bill.number}"
    puts "created bill #{bill_info}"

    create_latest_action(new_bill, bill)
    puts "created latest action #{bill_info}"

    create_sponsors(new_bill, json_response['bill']['sponsors'], true)

    if cosponsor_present?(json_response)
      cosponsors = fetch_cosponsor_data(new_bill)['cosponsors']
      create_sponsors(new_bill, cosponsors, false)
    end

    new_bill
  end

  def cosponsor_present?(json_response)
    cosponsor = json_response['bill']['cosponsors'].present? &&
                json_response['bill']['cosponsors']['count'].positive?
    puts "cosponsor present? #{cosponsor}"

    cosponsor
  end

  def create_latest_action(bill, data)
    LatestAction.create(
      bill_id: bill.id,
      action_date: data['latestAction']['actionDate'],
      text: data['latestAction']['text']
    )
  end

  def create_sponsors(bill, sponsors, primary = nil)
    # verify member exists, create if not
    # then create join record for bill and sponsor
    sponsors.each do |sponsor|
      member = Member.find_by(bio_guide_id: sponsor['bioguideId'])
      member = create_member(sponsor) if member.nil?
      member_info = "#{bill.id}, #{member.id}"
      primary == true ? BillSponsor.create(bill:, member:) : BillCoSponsor.create(bill:, member:)
      puts primary ? "created BillSponsor #{member_info}" : "created BillCoSponsor #{member_info}"
    end
  end

  # rubocop:disable Metrics/AbcSize
  def create_member(sponsor)
    member = fetch_member_data(sponsor['bioguideId'])['member']
    image_attribution = member['depiction'] ? member['depiction']['attribution'] : nil
    image_url = member['depiction'] ? member['depiction']['imageUrl'] : nil

    new_member = Member.create(
      bio_guide_id: sponsor['bioguideId'], birth_year: member['birthYear'],
      current_member: member['currentMember'], direct_order_name: member['directOrderName'],
      district: member['district'], first_name: member['firstName'],
      honorific_name: member['honorificName'], inverted_order_name: member['invertedOrderName'],
      last_name: member['lastName'], middle_name: member['middleName'],
      display_name: sponsor['fullName'], official_website_url: member['officialWebsiteUrl'],
      state: member['state'], update_date: member['updateDate'], party: sponsor['party'],
      image_attribution:, image_url:
    )
    create_address(new_member, member)

    puts "created new member #{new_member.display_name}"

    new_member
  end
  # rubocop:enable Metrics/AbcSize

  def create_address(new_member, member)
    Address.create(
      member_id: new_member.id,
      city: member['addressInformation']['city'],
      district: member['addressInformation']['district'],
      office_address: member['addressInformation']['officeAddress'],
      phone_number: member['addressInformation']['phoneNumber'],
      zip_code: member['addressInformation']['zip_code']
    )
  end

  def fetch_member_data(member_id)
    url = "https://api.congress.gov/v3/member/#{member_id}?format=json"
    response = HTTParty.get(url, headers: { 'X-Api-Key' => @api_key })

    raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

    response.parsed_response
  end

  def fetch_cosponsor_data(bill)
    # https://api.congress.gov/v3/bill/119/hr/30/cosponsors?format=json
    base = 'https://api.congress.gov/v3/bill/'
    url = "#{base}/#{bill.congress}/#{bill.bill_type.downcase}/#{bill.number}/cosponsors?format=json"
    response = HTTParty.get(url, headers: { 'X-Api-Key' => @api_key })

    raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

    response.parsed_response
  end

  def log_and_raise(error)
    Rails.logger.error("Job failed: #{error.message}")
    raise error
  end

  def fetch_api_key
    api_key = ENV.fetch('CONGRESS_KEY', nil)
    raise MissingApiKeyError, 'CONGRESS_KEY is missing! Check your .env file.' if api_key.nil? || api_key.strip.empty?

    api_key
  end

  class MissingApiKeyError < StandardError; end
  class ApiRequestError < StandardError; end
end
