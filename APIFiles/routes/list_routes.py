from flask import request, jsonify, Blueprint
from models.base_model import db
from models.list_model import List
from models.listOwnership_model import ListOwnership
from sqlalchemy import exc

list_api = Blueprint('list_api', __name__)

# Add a list
@list_api.route('/list', methods=['POST'])
def add_list():
  name = request.json['name']
  uuid = request.json['uuid']
  old = 0 # All lists start new

  new_list = List(name, old) # Create the new list
  db.session.add(new_list)

  db.session.flush() # Get the id from new_list

  new_owner = ListOwnership(uuid, new_list.list_id) # Update the ownership table with this new list so that the uuid owns it
  db.session.add(new_owner)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    return {"result": False}

  return {"result": True}