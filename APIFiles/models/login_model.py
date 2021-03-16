from flask import request, jsonify, Blueprint
from models.base_model import db, ma

login_api = Blueprint('login_api', __name__)

# Login Class/Model
class Login(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(100), unique=True)
  password = db.Column(db.String(100))

  def __init__(self, name, password):
    self.name = name
    self.password = password

# Login Schema
class LoginSchema(ma.Schema):
  class Meta:
    fields = ('id', 'name', 'password')

# Init schema
login_schema = LoginSchema()

# Create a Login
@login_api.route('/login', methods=['POST'])
def add_login():
  name = request.json['name']
  password = request.json['password']

  new_login = Login(name, password)

  db.session.add(new_login)
  db.session.commit()

  return login_schema.jsonify(new_login)

# Get Single Login
@login_api.route('/login/<id>', methods=['GET'])
def get_login(id):
  login = Login.query.get(id)
  return login_schema.jsonify(login)