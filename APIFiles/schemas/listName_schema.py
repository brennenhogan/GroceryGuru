from schemas.base_schema import ma
from marshmallow import fields

# List Schema
class ListNameSchema(ma.Schema):
  list_id = fields.Integer()
  list_name = fields.Str()
  list_old = fields.Integer()

# Init schema
listName_schema = ListNameSchema()