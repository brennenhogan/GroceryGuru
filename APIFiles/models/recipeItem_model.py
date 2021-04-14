from models.base_model import db
from models.store_model import Store
from models.recipe_model import Recipe

# RecipeItem Class/Model
class RecipeItem(db.Model):
  item_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  recipe_id = db.Column(db.Integer, db.ForeignKey('recipe.recipe_id'))
  store_id = db.Column(db.Integer, db.ForeignKey('recipe_store.store_id'), nullable=False)
  qty = db.Column(db.Integer, nullable=False)
  description = db.Column(db.String(100), nullable=False)

  def __init__(self, recipe_id, store_id, qty, description):
    self.recipe_id = recipe_id
    self.store_id = store_id
    self.qty = qty
    self.description = description

  def get_store(self):
    return self.store_id