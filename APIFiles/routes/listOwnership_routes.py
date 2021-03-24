from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listOwnership_model import ListOwnership
from models.list_model import List
from schemas.listOwnership_schema import listOwnership_schema
from schemas.list_schema import list_schema
from schemas.listName_schema import listName_schema
from sqlalchemy import exc

listOwnership_api = Blueprint('listOwnership_api', __name__)

# Share a list to another user)
@listOwnership_api.route('/share', methods=['POST'])
def add_owner():
  uuid = request.json['uuid']
  list_id = request.json['list_id']

  new_owner = ListOwnership(uuid, list_id)

  db.session.add(new_owner)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    return {"result": False}

  return {"result": True}

# LANDING PAGE QUERY #
# See all lists for a user (ListOwnership.list_id, List.name, List.old)
@listOwnership_api.route('/owner/<user_uuid>', methods=['GET'])
def get_listids(user_uuid):
  lists = db.session.query(ListOwnership, List)\
    .join(List, List.list_id == ListOwnership.list_id)\
    .filter(ListOwnership.uuid==user_uuid).all()

  all_lists = [] # Extract the data from the queried objects
  for l_obj in lists:
    ListOwnershipObj = l_obj._asdict()['ListOwnership'] # Get the models
    ListObj = l_obj._asdict()['List']

    temp = {"list_id": ListOwnershipObj.get_list_id(), "list_name": ListObj.get_name(), "list_old": ListObj.get_old()} # Use the model methods to get the data
    all_lists.append(temp)

  return listName_schema.jsonify(all_lists, many=True) # Return the data using the listName schema
