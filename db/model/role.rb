class Role

  include Model

  field :name, type: String
  field :slug, type: Symbol

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  # Returns lisf of registered slugs
  #
  def self.slugs
    self.only(:slug).map(&:slug)
  end

end # class Role