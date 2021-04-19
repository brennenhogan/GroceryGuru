from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listItem_model import ListItem
from models.store_model import Store
from models.list_model import List
from models.listOwnership_model import ListOwnership
from schemas.list_schema import list_schema
from sqlalchemy import exc
from routes.utils import update_version

listItem_api = Blueprint('listItem_api', __name__)

# Add an item
@listItem_api.route('/item', methods=['POST'])
def add_item():
  list_id = request.json['list_id']
  store_id = request.json['store_id'] # Store must be added for user to add items to that store, so this works
  qty = request.json['qty']
  description = request.json['description']
  purchased = 0 # All items start unpurchased

  new_item = ListItem(list_id, store_id, qty, description, purchased)
 
  db.session.add(new_item)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(list_id)
  return {"result": True}

# Update the quantity of an item
@listItem_api.route('/item/qty', methods=['POST'])
def update_qty():
  item_id = request.json['item_id']
  qty = request.json['item_qty']
 
  item = ListItem.query.filter(ListItem.item_id==item_id).first() # Get the item from the DB
  item.qty = qty # update the quantity

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(item.list_id)
  return {"result": True}

# Update the name of an item
@listItem_api.route('/item/description', methods=['POST'])
def update_description():
  item_id = request.json['item_id']
  description = request.json['description']
 
  item = ListItem.query.filter(ListItem.item_id==item_id).first() # Get the item from the DB
  item.description = description # update the description

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(item.list_id)
  return {"result": True}

# Check off an item
@listItem_api.route('/item/check', methods=['POST'])
def update_purchased():
  item_id = request.json['item_id']
  purchased = request.json['purchased']
 
  item = ListItem.query.filter(ListItem.item_id==item_id).first() # Get the item from the DB
  item.purchased = purchased # update the purchased field
  list_id = item.list_id # Store the list ID for later

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  # See if there are any un-purchased items on the list.  If not, mark it as an old list
  unpurchased = ListItem.query.filter(ListItem.list_id==list_id).filter(ListItem.purchased==0).all()
  if not unpurchased:
    listObj = List.query.filter(List.list_id==list_id).first() # Get the item from the DB
    listObj.old = 1 # update the old property of the list

    try:
      db.session.commit()
    except exc.SQLAlchemyError:
      print(exc.SQLAlchemyError)
      return {"result": False}

  update_version(item.list_id)
  return {"result": True}

# Delete an item
@listItem_api.route('/item/delete', methods=['POST'])
def delete_item():
  item_id = request.json['item_id']
 
  item = ListItem.query.filter(ListItem.item_id==item_id).first() # Get the item from the DB
  db.session.delete(item)
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  update_version(item.list_id)
  return {"result": True}

# INDIVIDUAL LIST QUERY #
# Get a list by ID
@listItem_api.route('/list/<id>/<user_uuid>/<purchased>', methods=['GET'])
def get_list(id, user_uuid, purchased):
  owner = db.session.query(ListOwnership).filter(ListOwnership.uuid==user_uuid).filter(ListOwnership.list_id==id).all()
  
  if not owner:
    return {"result": False}

  stores = Store.query.filter(Store.list_id==id).all()
  
  listFragments = []
  for store in stores:
    store_id = store.get_id()
    store = db.session.query(Store).filter(Store.store_id==store_id).one() # Store_ids are distinct

    store_items = None
    if purchased == '1':
      store_items = db.session.query(ListItem)\
        .filter(ListItem.list_id==id)\
        .filter(ListItem.store_id==store_id)\
        .filter(ListItem.purchased==0)\
        .all()
    else:
      store_items = db.session.query(ListItem)\
        .filter(ListItem.list_id==id)\
        .filter(ListItem.store_id==store_id)\
        .all()
    
    listFragment = {"name": store.get_name(), "store_id": store_id,"items": store_items}
    listFragments.append(listFragment)
  
  matchingList = List.query.filter(List.list_id==id).first()

  return list_schema.jsonify({"version": matchingList.get_version(), "stores": listFragments})
