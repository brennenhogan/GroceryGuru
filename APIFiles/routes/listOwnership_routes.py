from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listOwnership_model import ListOwnership
from models.list_model import List
from models.listItem_model import ListItem
from models.login_model import Login
from schemas.listOwnership_schema import listOwnership_schema
from schemas.listName_schema import listName_schema
from sqlalchemy import exc

listOwnership_api = Blueprint('listOwnership_api', __name__)

# Share a list to another user)
@listOwnership_api.route('/share', methods=['POST'])
def add_owner():
  name = request.json['name']
  list_id = request.json['list_id']

  user = Login.query.filter_by(name=name).first()

  # If the user does not already exist, throw an error
  if not user:
    return {"result": False, "message": "User does not exist"}
  
  owners = ListOwnership.query.filter_by(list_id=list_id).all()

  # If the user is already an owner, do not share with the user
  for owner in owners:
    if owner.uuid == user.uuid:
      return {"result": False, "message": "User is already an owner"}

  print(user.uuid)
  new_owner = ListOwnership(user.uuid, list_id)

  db.session.add(new_owner)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    return {"result": False, "message": "SQLAlchemy Error"}

  return {"result": True, "message": "Share successful"}

# LANDING PAGE QUERY #
# See all lists for a user (ListOwnership.list_id, List.name, List.old)
@listOwnership_api.route('/owner/<user_uuid>/<old>', methods=['GET'])
def get_listids(user_uuid, old):
  lists = db.session.query(ListOwnership, List)\
    .join(List, List.list_id == ListOwnership.list_id)\
    .filter(ListOwnership.uuid==user_uuid)\
    .filter(List.old==old).all()

  all_lists = [] # Extract the data from the queried objects
  for l_obj in lists:
    ListOwnershipObj = l_obj._asdict()['ListOwnership'] # Get the models
    ListObj = l_obj._asdict()['List']

    list_id = ListOwnershipObj.get_list_id()
    list_qty = ListItem.query.filter(ListItem.list_id==list_id).count()

    temp = {"list_id": list_id, "list_name": ListObj.get_name(), "list_old": ListObj.get_old(), "list_qty": list_qty} # Use the model methods to get the data
    all_lists.append(temp)

  return listName_schema.jsonify(all_lists, many=True) # Return the data using the listName schema
