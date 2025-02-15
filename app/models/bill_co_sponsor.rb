class BillCoSponsor < ApplicationRecord
  belongs_to :bill
  belongs_to :member
end
