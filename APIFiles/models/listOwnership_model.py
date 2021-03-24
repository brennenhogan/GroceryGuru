from models.base_model import db
from models.login_model import Login

# List Class/Model
class ListOwnership(db.Model):
  user_id = db.Column(db.Integer, db.ForeignKey('login.id'), primary_key=True)
  list_id = db.Column(db.Integer, primary_key=True)

  def __init__(self, user_id, list_id):
    self.user_id = user_id
    self.list_id = list_id