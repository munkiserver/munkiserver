module HasAnEnvironment
  def self.included(base)
    base.class_eval do
      belongs_to :environment

      scope :environment, ->(p) { where(:environment_id => p.id) }
      scope :environment_ids, ->(ids) { where(:environment_id => ids) }
      scope :environments, ->(p) { where(:environment_id => p.collect(&:id)) }

      validates_presence_of :environment_id
    end
  end
end
