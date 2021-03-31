from schemas.base_schema import ma

# Recipe Schema
class RecipeSchema(ma.Schema):
  class Meta:
    fields = ('recipe_id', 'name')

# Init schema
recipe_schema = RecipeSchema()