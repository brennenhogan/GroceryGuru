from flask import request, jsonify, Blueprint
from models.base_model import db
from models.login_model import Login
from schemas.login_schema import login_schema

login_api = Blueprint('login_api', __name__)

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