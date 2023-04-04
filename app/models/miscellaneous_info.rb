# == Schema Information
#
# Table name: miscellaneous_infos
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  value      :text
#  created_at :timestamp
#  updated_at :timestamp
#

class MiscellaneousInfo < ApplicationRecord
end
