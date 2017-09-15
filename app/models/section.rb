class Section < ApplicationRecord

  has_many :comments

  def section_and_number
    "#{course_description}-#{section_number}"
  end
end
