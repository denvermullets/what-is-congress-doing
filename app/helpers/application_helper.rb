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
end
