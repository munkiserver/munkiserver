module HasAUnit
  # Used to augment the class definition
  # of the class passed as an argument
  # Put class customization in here!
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      belongs_to :unit

      scope :unit, ->(u) { u.present? ? where(unit_id: u.id) : where(unit_id: nil) }
      scope :not_unit, ->(u) { where("#{to_s.tableize}.unit_id <> ?", u.id) }

      validates :unit_id, presence: true
    end
  end

  module ClassMethods
    # Returns a list of type self that belong to the same unit and environment as unit_member
    def unit_member(unit_member)
      unit(unit_member.unit).environments([unit_member.environment])
    end

    # Instatiates a new object, belonging to unit.  Caches for future calls.
    def new_for_can(unit)
      raise ArgumentError, "Unit passed to new_for_can is nil" if unit.nil?
      @new_for_can ||= []
      @new_for_can[unit.id] ||= new(unit: unit)
    end
  end

  # Array of catalogs this unit member belongs to
  def catalogs
    ["#{unit.id}-#{environment}.plist"]
  end
end
