from schemas.base_schema import ma
from marshmallow import fields
from schemas.completeList_schema import CompleteListSchema

# List Wrapper Schema
class ListWrapperSchema(ma.Schema):
  data = fields.Nested(CompleteListSchema(many=True))

# Init schema
listWrapper_schema = ListWrapperSchema()