from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listItem_model import ListItem
from models.store_model import Store
from models.listOwnership_model import ListOwnership
from schemas.listItem_schema import listItem_schema
from schemas.store_schema import store_schema
from schemas.listWrapper_schema import listWrapper_schema
from sqlalchemy import exc

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

  return {"result": True}

# Update the quantity of an item
@listItem_api.route('/item/qty', methods=['POST'])
def update_qty():
  item_id = request.json['item_id']
  qty = request.json['qty']
 
  item = ListItem.query.filter(ListItem.item_id==item_id).first() # Get the item from the DB
  item.qty = qty # update the quantity

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

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

  return {"result": True}

# INDIVIDUAL LIST QUERY #
# Get a list by ID
@listItem_api.route('/list/<id>/<user_uuid>', methods=['GET'])
def get_list(id, user_uuid):
  owner = db.session.query(ListOwnership).filter(ListOwnership.uuid==user_uuid).filter(ListOwnership.list_id==id).all()
  
  if not owner:
    print("INVALID REQUEST - No permissions")
    return {"result": False}

  stores = db.session.query(ListItem.store_id).filter(ListItem.list_id==id).distinct().all()
  distinct_store_ids = [store._asdict()['store_id'] for store in stores] # Get the ids of the stores for a list
  
  listFragments = []
  for store_id in distinct_store_ids:
    store = db.session.query(Store).filter(Store.store_id==store_id).one() # Store_ids are distinct

    store_items = db.session.query(ListItem)\
      .filter(ListItem.list_id==id)\
      .filter(ListItem.store_id==store_id)\
      .all()
    
    listFragment = {"name": store.get_name(), "items": store_items}
    listFragments.append(listFragment)
  
  wrapped = {"data": listFragments}
  return listWrapper_schema.jsonify(wrapped)
