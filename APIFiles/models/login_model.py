from models.base_model import db

# Login Class/Model
class Login(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(100), unique=True)
  password = db.Column(db.String(100))
  uuid = db.Column(db.String(25), unique=True)

  def __init__(self, name, password, uuid):
    self.name = name
    self.password = password
    self.uuid = uuid
