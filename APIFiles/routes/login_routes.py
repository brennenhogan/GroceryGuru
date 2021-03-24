from flask import request, jsonify, Blueprint
from models.base_model import db
from models.login_model import Login
from schemas.login_schema import login_schema
import random
import string

login_api = Blueprint('login_api', __name__)

LETTERS = string.ascii_lowercase

# Login to an Existing Account
# Returns True if the user has entered the correct password or False otherwise 
# False is accompanied by an additional error message
@login_api.route('/login', methods=['POST'])
def login():
  name = request.json['name']
  password = request.json['password']
  user =  Login.query.filter_by(name=name).first()

  if user:
    return {"result": True, "message": "Successful login", "uuid": user.uuid} if password == user.password else {"result": False, "message": "ERROR: Incorrect password", "uuid": ""}
  
  return {"result": False, "message": "ERROR: User does not exist", "uuid": ""}

# Create a New Account
@login_api.route('/users', methods=['POST'])
def create():
  name = request.json['name']
  password = request.json['password']
  uuid = "".join(random.choice(LETTERS) for i in range(25))

  new_login = Login(name, password, uuid)

  db.session.add(new_login)
  db.session.commit()

  return {"uuid": new_login.uuid}

# Get Single Login
@login_api.route('/login/<id>', methods=['GET'])
def get_login(id):
  login = Login.query.get(id)
  return login_schema.jsonify(login)