class Pagegroup
  include DataMapper::Resource

  property :id,          Serial
  property :name,        String
  property :description, String

  has n, :contacts, :through => Resource
end
