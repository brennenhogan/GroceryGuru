from models.base_model import db
from models.store_model import Store

# List Class/Model
class ListItem(db.Model):
  item_id = db.Column(db.Integer, primary_key=True)
  list_id = db.Column(db.Integer, primary_key=True)
  store_id = db.Column(db.Integer, db.ForeignKey('store.store_id'))
  qty = db.Column(db.Integer)
  description = db.Column(db.String(100))
  purchased = db.Column(db.Integer)

  def __init__(self, item_id, list_id, store, qty, description, purchased):
    self.item_id = item_id
    self.list_id = list_id
    self.store = store
    self.qty = qty
    self.description = description
    self.purchased = purchased