from models.base_model import db

# List Class/Model
class List(db.Model):
  list_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  name = db.Column(db.String(100), nullable=False)
  old = db.Column(db.Integer, nullable=False)

  def __init__(self, name, old):
    self.name = name
    self.old = old

  def get_name(self):
    return self.name
  
  def get_old(self):
    return self.old
