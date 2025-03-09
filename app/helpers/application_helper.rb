module ApplicationHelper
  def generate_stars(rating)
    empty = 10 - rating
    stars = ''

    rating.times do
      stars += '&#9733;'
    end

    empty.times do
      stars += '&#9734;'
    end

    stars
  end

  def get_abbr(name)
    name.scan(/\[(.*?)\]/).flatten.first
  end

  def strip_abbr(name)
    name.gsub(/\[.*?\]/, '')
  end

  # rubocop:disable Lint/DuplicateBranch
  def determine_bill_status(bill)
    status = bill.latest_actions.order(:action_date).last.text.downcase

    if status.include?('committee')
      'passed_house'
    elsif status.include?('received in the senate')
      # i think??
      'passed_senate'
    elsif status.include?('submitted in the senate')
      'passed_house'
    else
      'passed_house'
    end
  end
  # rubocop:enable Lint/DuplicateBranch
end
