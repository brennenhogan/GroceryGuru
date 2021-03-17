from models.base_model import db

# Login Class/Model
class Login(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(100), unique=True)
  password = db.Column(db.String(100))

  def __init__(self, name, password):
    self.name = name
    self.password = password
