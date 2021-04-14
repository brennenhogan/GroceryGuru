from models.base_model import db

# List Class/Model
class RecipeStore(db.Model):
  store_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  store_name = db.Column(db.String(50), nullable=False)
  recipe_id = db.Column(db.Integer, nullable=False)

  def __init__(self, store_name, recipe_id):
    self.store_name = store_name
    self.recipe_id = recipe_id

  def get_name(self):
    return self.store_name

  def get_id(self):
    return self.store_id

  def get_recipe_id(self):
    return self.recipe_id