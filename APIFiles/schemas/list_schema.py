from schemas.base_schema import ma
from marshmallow import fields
from schemas.completeList_schema import CompleteListSchema

# List Schema
class ListSchema(ma.Schema):
  version = fields.Str() 
  stores = fields.Nested(CompleteListSchema(many=True)) # We want many stores for this list

# Init schema
list_schema = ListSchema()