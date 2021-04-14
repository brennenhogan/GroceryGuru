from schemas.base_schema import ma

# RecipeItem Schema
class RecipeItemSchema(ma.Schema):
  class Meta:
    fields = ('item_id', 'recipe_id', 'qty', 'description', 'checked')

# Init schema
recipeItem_schema = RecipeItemSchema()