from schemas.base_schema import ma

# List Schema
class RecipeStoreSchema(ma.Schema):
  class Meta:
    fields = ('store_id', 'store_name', "recipe_id")

# Init schema
recipeStore_schema = RecipeStoreSchema()