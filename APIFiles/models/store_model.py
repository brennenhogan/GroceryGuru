from models.base_model import db

# List Class/Model
class Store(db.Model):
  store_id = db.Column(db.Integer, primary_key=True)
  store_name = db.Column(db.String(50))

  def __init__(self, store_id, store_name):
    self.store_id = store_id
    self.store_name = store_name

  def get_name(self):
    return self.store_name

  def get_id(self):
    return self.store_id