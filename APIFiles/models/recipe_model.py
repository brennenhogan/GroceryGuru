from models.base_model import db

# Recipe Class/Model
class Recipe(db.Model):
  recipe_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
  name = db.Column(db.String(100), nullable=False)
  uuid = db.Column(db.Integer, db.ForeignKey('login.uuid'), nullable=False)

  def __init__(self, name, uuid):
    self.name = name
    self.uuid = uuid

  def get_name(self):
    return self.name
