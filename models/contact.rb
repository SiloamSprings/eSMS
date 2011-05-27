class Contact
  include DataMapper::Resource

  property :id,     Serial
  property :name,   String
  property :number, String

  has n, :pagegroups, :through => Resource
end
