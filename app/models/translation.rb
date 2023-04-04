# == Schema Information
#
# Table name: translations
#
#  id             :integer          not null, primary key
#  locale         :string(255)
#  key            :string(255)
#  value          :string(255)
#  interpolations :string(255)
#  is_proc        :boolean          default(FALSE)
#  created_at     :timestamp        not null
#  updated_at     :timestamp        not null
#

class Translation < ApplicationRecord

end
