class ApiKey < ActiveRecord::Base
  attr_accessible :key, :user_id

  belongs_to :user
  validates :user, presence: true
  validates :key, presence: true, uniqueness: true

  after_initialize :generate_key

  def self.find_user(key)
    key = ApiKey.find_by_key(key)
    key.user if key
  end

  def self.find_user!(key)
    user = find_user(key)
    if user
      user
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def generate_key
    self.key ||= SecureRandom.hex(32)
  end
end
