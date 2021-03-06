from flask import request, jsonify, Blueprint
from models.base_model import db
from models.list_model import List
from models.listItem_model import ListItem
from models.store_model import Store
from models.recipeStore_model import RecipeStore
from models.listOwnership_model import ListOwnership
from models.recipeItem_model import RecipeItem
from sqlalchemy import exc
from routes.utils import update_version

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

# Create a list from a recipe
@list_api.route('/list/recipecreate', methods=['POST'])
def create_list_from_recipe():
  name = request.json['name']
  uuid = request.json['uuid']
  recipe_id = request.json['recipe_id']
  old = 0 # All lists start new

  new_list = List(name, old) # Create the new list
  db.session.add(new_list)

  db.session.flush() # Get the id from new_list
  new_list_id = new_list.list_id

  new_owner = ListOwnership(uuid, new_list_id) # Update the ownership table with this new list so that the uuid owns it
  db.session.add(new_owner)

  # Create new stores for each item
  store_mappings = {}
  stores = db.session.query(RecipeItem.store_id).filter(RecipeItem.recipe_id==recipe_id).filter(RecipeItem.checked=='0').distinct().all()

  for store_obj in stores:
    store_id = store_obj._asdict()['store_id']
    store = RecipeStore.query.filter(RecipeStore.store_id==store_id).first()

    new_store = Store(store.get_name(), new_list_id) # Create new store
    db.session.add(new_store) # Insert new store

    db.session.flush() # Get the id from new_store

    store_mappings[store_id] = new_store.store_id # Update store_mappings with mappings so later we can use the new store ids

  items = RecipeItem.query.filter(RecipeItem.recipe_id==recipe_id).filter(RecipeItem.checked=='0').all() # Get all items for the recipe
  for item in items:
    new_item = ListItem(new_list_id, store_mappings[item.get_store()], item.get_qty(), item.get_description(), 0) # All items start unpurchased - hence the 0
    db.session.add(new_item)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    return {"list_id": -1,"result": False}

  return {"list_id": new_list_id, "result": True}

# Import a recipe into a list
@list_api.route('/list/recipeimport', methods=['POST'])
def import_recipe():
  list_id = request.json['list_id']
  recipe_id = request.json['recipe_id']

  # Get the store names for the recipe
  store_names = []
  store_ids = db.session.query(RecipeItem.store_id).filter(RecipeItem.recipe_id==recipe_id).filter(RecipeItem.checked=='0').distinct().all()
  for store_obj in store_ids:
    store_id = store_obj._asdict()['store_id']
    store = RecipeStore.query.filter(RecipeStore.store_id==store_id).first()
    store_names.append((store.get_name(), store_id))

  # Check for a matching store in the list (otherwise create a new store)
  store_mappings = {}
  for store_name, store_id in store_names:
    search = "{}%".format(store_name[:3]) # Search for a store that already exists for that list with the same name
    corresponding_store = Store.query.filter(Store.list_id==list_id).filter(Store.store_name.like(search)).first()

    if corresponding_store: # Found a corresponding store
      store_mappings[store_id] = corresponding_store.get_id()
    else: # Didn't find a coresponding store - so create a new store
      new_store = Store(store_name, list_id)
      db.session.add(new_store)
      db.session.flush()
      store_mappings[store_id] = new_store.store_id # Update store_mappings so later we can use the new store ids


  items = RecipeItem.query.filter(RecipeItem.recipe_id==recipe_id).filter(RecipeItem.checked=='0').all() # Get all items for the recipe
  for item in items:
    new_item = ListItem(list_id, store_mappings[item.get_store()], item.get_qty(), item.get_description(), 0) # All items start unpurchased - hence the 0
    db.session.add(new_item)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    return {"result": False}

  update_version(list_id)
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
  items = ListItem.query.filter(ListItem.list_id==list_id).filter(ListItem.deleted==0).all() # Get all items for the list with list_id == list_id
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
  print(ownership_lists)
  
  # Deletes the entry from both tables if only one owner exists
  if len(ownership_lists) == 1:
    db.session.delete(current_list)
    db.session.delete(ownership_lists[0])

    stores = Store.query.filter(Store.list_id==list_id).all()
    items = ListItem.query.filter(ListItem.list_id==list_id).all()
    # Do not delete stores to preserve their unique id as well
    for item in items:
      item.deleted = 1 # This preserves the item_id in the table
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

# Get a list's version number
@list_api.route('/list/<id>/<user_uuid>/version', methods=['GET'])
def get_list(id, user_uuid):
  owner = db.session.query(ListOwnership).filter(ListOwnership.uuid==user_uuid).filter(ListOwnership.list_id==id).all()
  
  if not owner:
    return {"result": False}

  matchingList = List.query.filter(List.list_id==id).first()

  if not matchingList:
    return {"version": 0, "result": False}
  else:
    return {"version": matchingList.get_version(), "result": True}
