from schemas.base_schema import ma
from marshmallow import fields

# List Schema
class ListOwnershipSchema(ma.Schema):
  uuid = fields.Str()
  list_id = fields.Str()

# Init schema
listOwnership_schema = ListOwnershipSchema()