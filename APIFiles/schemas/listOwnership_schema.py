from schemas.base_schema import ma

# List Schema
class ListOwnershipSchema(ma.Schema):
  class Meta:
    fields = ('uuid', 'list_id')

# Init schema
listOwnership_schema = ListOwnershipSchema()