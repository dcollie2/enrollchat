class Setting < ApplicationRecord

  # Rails Singleton Model
  # Taken from:
  #           http://stackoverflow.com/questions/399447/how-to-implement-a-singleton-model/12463209#12463209

  # The "singleton_guard" column is a unique column which must always be set to '0'
  # This ensures that only one AppSettings row is created
  validates :singleton_guard, inclusion: { in: [0] }

  def self.instance
    # there will be only one row, and its ID must be '1'
    begin
      find(1)
    rescue ActiveRecord::RecordNotFound
      # slight race condition here, but it will only happen once
      row = Setting.new
      row.singleton_guard = 0
      row.save!
      row
    end
  end

  def self.method_missing(method, *args)
    if Setting.instance.methods.include?(method)
      Setting.instance.send(method, *args)
    else
      super
    end
  end

  # End Rails Singleton Model

  validates :current_term, format: { with: /\d{6}/, message: 'must be blank or have exactly six numbers'}, allow_blank: true

end