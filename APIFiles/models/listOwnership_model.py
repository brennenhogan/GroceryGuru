from models.base_model import db
from models.login_model import Login

# List Class/Model
class ListOwnership(db.Model):
  uuid = db.Column(db.Integer, db.ForeignKey('login.uuid'), primary_key=True)
  list_id = db.Column(db.Integer, primary_key=True)

  def __init__(self, uuid, list_id):
    self.uuid = uuid
    self.list_id = list_id