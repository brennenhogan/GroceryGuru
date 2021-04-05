from models.base_model import db
from models.store_model import Store

# List Class/Model
class ListItem(db.Model):
  item_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  list_id = db.Column(db.Integer)
  store_id = db.Column(db.Integer, db.ForeignKey('store.store_id'), nullable=False)
  qty = db.Column(db.Integer, nullable=False)
  description = db.Column(db.String(100), nullable=False)
  purchased = db.Column(db.Integer, nullable=False)

  def __init__(self, list_id, store_id, qty, description, purchased):
    self.list_id = list_id
    self.store_id = store_id
    self.qty = qty
    self.description = description
    self.purchased = purchased

  def get_store(self):
    return self.store_id
      
  def get_qty(self):
    return self.qty
      
  def get_description(self):
    return self.description