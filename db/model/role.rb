class Role

  include Model

  field :name, type: String
  field :slug, type: Symbol

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

end # class Role