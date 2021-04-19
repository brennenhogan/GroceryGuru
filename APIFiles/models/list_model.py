from models.base_model import db

# List Class/Model
class List(db.Model):
  list_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  name = db.Column(db.String(100), nullable=False)
  old = db.Column(db.Integer, nullable=False)
  version = db.Column(db.Integer, default=1) # The version is initially version 1

  def __init__(self, name, old):
    self.name = name
    self.old = old

  def get_name(self):
    return self.name
  
  def get_old(self):
    return self.old

  def get_version(self):
    return self.version
