from flask import request, jsonify, Blueprint
from models.base_model import db
from models.store_model import Store
from models.listItem_model import ListItem
from models.listOwnership_model import ListOwnership
from schemas.store_schema import store_schema
from sqlalchemy import exc
from routes.utils import update_version

store_api = Blueprint('store_api', __name__)

# Add a store
@store_api.route('/store', methods=['POST'])
def add_store():
  store_name = request.json['store_name']
  list_id = request.json['list_id']

  new_store = Store(store_name, list_id)

  db.session.add(new_store)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False, "store_id": 0}

  update_version(list_id)
  return {"result": True, "store_id": new_store.store_id}

# Edit a store name
@store_api.route('/store/description', methods=['POST'])
def edit_store():
  store_name = request.json['store_name']
  store_id = request.json['store_id']
  list_id = request.json['list_id']
 
  selected_store = Store.query.filter(Store.store_id==store_id).filter(Store.list_id==list_id).first() # Get the list from the DB
  selected_store.store_name = store_name
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(list_id)
  return {"result": True}

# Delete a store (and all of its items!)
@store_api.route('/store/delete', methods=['POST'])
def delete_store():
  store_id = request.json['store_id'] # store ids are unique to each list so we can delete items that belong to the store safely
  list_id = request.json['list_id']
  uuid = request.json["uuid"]

  owner = db.session.query(ListOwnership).filter(ListOwnership.uuid==uuid).filter(ListOwnership.list_id==list_id).all()
  
  if not owner: # Make sure they have permission to delete this store
    return {"result": False}

  items = ListItem.query.filter(ListItem.store_id==store_id).all() # Get all items for the list with store_id == store_id

  for item in items:
    item.deleted = 1

  store = Store.query.filter(Store.store_id==store_id).one()
  db.session.delete(store)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(list_id)
  return {"result": True}
