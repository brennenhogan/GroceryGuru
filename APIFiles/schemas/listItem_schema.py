from schemas.base_schema import ma

# List Schema
class ListItemSchema(ma.Schema):
  class Meta:
    fields = ('item_id', 'list_id', 'store', 'qty', 'description', 'purchased') # TODO - add 'store'

# Init schema
listItem_schema = ListItemSchema()