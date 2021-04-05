from schemas.base_schema import ma
from marshmallow import fields
from schemas.listItem_schema import ListItemSchema

# List Schema
class CompleteListSchema(ma.Schema):
  name = fields.Str()
  store_id = fields.Integer()
  items = fields.Nested(ListItemSchema(many=True)) # We want many list items for each store

# Init schema
completeList_schema = CompleteListSchema()