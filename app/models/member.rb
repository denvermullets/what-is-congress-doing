class Member < ApplicationRecord
  has_one :address, dependent: :destroy
  has_many :party_histories, dependent: :destroy

  has_many :bill_sponsors, dependent: :destroy
  has_many :sponsored_bills, through: :bill_sponsors, source: :bill

  has_many :bill_co_sponsors, dependent: :destroy
  has_many :co_sponsored_bills, through: :bill_co_sponsors, source: :bill
end
