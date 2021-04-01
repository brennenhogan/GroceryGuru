from schemas.base_schema import ma
from marshmallow import fields
from schemas.recipeItem_schema import RecipeItemSchema

# List Schema
class CompleteRecipeSchema(ma.Schema):
  name = fields.Str()
  items = fields.Nested(RecipeItemSchema(many=True)) # We want many recipe items for each store

# Init schema
completeRecipe_schema = CompleteRecipeSchema()