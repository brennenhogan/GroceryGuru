from models.base_model import db

# List Class/Model
class List(db.Model):
  list_id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(100))
  old = db.Column(db.Integer)

  def __init__(self, list_id, name, old):
    self.list_id = list_id
    self.name = name
    self.old = old

  def get_name(self):
    return self.name
  
  def get_old(self):
    return self.old
