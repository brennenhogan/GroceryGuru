from models.base_model import db

# List Class/Model
class Store(db.Model):
  store_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  store_name = db.Column(db.String(50), nullable=False)
  list_id = db.Column(db.Integer, db.ForeignKey('list.list_id'), nullable=False)

  def __init__(self, store_name, list_id):
    self.store_name = store_name
    self.list_id = list_id

  def get_name(self):
    return self.store_name

  def get_id(self):
    return self.store_id

  def get_list_id(self):
    return self.list_id