from schemas.base_schema import ma

# List Schema
class ListSchema(ma.Schema):
  class Meta:
    fields = ('list_id', 'name', 'old')

# Init schema
list_schema = ListSchema()