from flask import request, jsonify, Blueprint
from models.base_model import db
from models.list_model import List
from models.listItem_model import ListItem
from models.store_model import Store
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
    return {"list_id": -1,"result": False}

  print(new_list.list_id)
  print({"list_id": new_list.list_id, "result": True})
  return {"list_id": new_list.list_id, "result": True}

# Update the name of a list
@list_api.route('/list/update', methods=['POST'])
def update_name():
  name = request.json['name']
  list_id = request.json['list_id']
 
  selected_list = List.query.filter(List.list_id==list_id).first() # Get the list from the DB
  selected_list.name = name
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Create a new list from old list
@list_api.route('/list/old', methods=['POST'])
def create_from_oldlist():
  name = request.json['name']
  uuid = request.json['uuid']
  old = 0 # All lists start new

  new_list = List(name, old) # Create the new list
  db.session.add(new_list)

  db.session.flush() # Get the id from new_list

  new_owner = ListOwnership(uuid, new_list.list_id) # Update the ownership table with this new list so that the uuid owns it
  db.session.add(new_owner)
 
  list_id = request.json['list_id']

  # Create new stores for each item
  store_mappings = {}
  stores = db.session.query(Store.store_id).filter(Store.list_id==list_id).distinct().all()

  for store_obj in stores:
    store_id = store_obj._asdict()['store_id']
    store = Store.query.filter(Store.store_id==store_id).first()

    new_store = Store(store.get_name(), new_list.list_id) # Create new store
    db.session.add(new_store) # Insert new store

    db.session.flush() # Get the id from new_store

    store_mappings[store.get_id()] = new_store.store_id # Update store_mappings with mappings so later we can use the new store ids

  # Insert new items
  items = ListItem.query.filter(ListItem.list_id==list_id).all() # Get all items for the list with list_id == list_id
  for item in items:
    new_item = ListItem(new_list.list_id, store_mappings[item.get_store()], item.get_qty(), item.get_description(), 0) # Items start off unpurchased.  Use the new stores
    db.session.add(new_item)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False, "list_id": 0}

  return {"result": True, "list_id": new_list.list_id}

# Delete a list
@list_api.route('/list/delete', methods=['POST'])
def delete_list():
  list_id = request.json['list_id']
  uuid = request.json["uuid"]
 
  ownership_lists = ListOwnership.query.filter(ListOwnership.list_id==list_id).all() # Get the list from the DB
  current_list = List.query.filter(List.list_id==list_id).first() # Get the list from the DB
  
  # Deletes the entry from both tables if only one owner exists
  if len(ownership_lists) == 1:
    db.session.delete(current_list)
    db.session.delete(ownership_lists[0])

    stores = Store.query.filter(Store.list_id==list_id).all()
    items = ListItem.query.filter(ListItem.list_id==list_id).all()
    for store in stores:
      db.session.delete(store)
    for item in items:
      db.session.delete(item)
  else: #Deletes only the ownership for the current user if there are multiple owners
    for owner in ownership_lists:
      if owner.uuid == uuid:
        db.session.delete(owner)
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}