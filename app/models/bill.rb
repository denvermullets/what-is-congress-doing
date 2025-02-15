class Bill < ApplicationRecord
  has_many :bill_sponsors, dependent: :destroy
  has_many :sponsors, through: :bill_sponsors, source: :member

  has_many :bill_co_sponsors, dependent: :destroy
  has_many :co_sponsors, through: :bill_co_sponsors, source: :member

  has_many :latest_actions, dependent: :destroy

  # bill_types can be: "HR", "S", "HJRES", "SJRES", "HCONRES", "SCONRES", "HRES", and "SRES"
end
