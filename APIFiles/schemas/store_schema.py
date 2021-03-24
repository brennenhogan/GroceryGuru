from schemas.base_schema import ma

# List Schema
class StoreSchema(ma.Schema):
  class Meta:
    fields = ('store_id', 'store_name') # TODO - add 'store'

# Init schema
store_schema = StoreSchema()