from schemas.base_schema import ma

# List Schema
class ListItemSchema(ma.Schema):
  class Meta:
    fields = ('item_id', 'list_id', 'qty', 'description', 'purchased')

# Init schema
listItem_schema = ListItemSchema()