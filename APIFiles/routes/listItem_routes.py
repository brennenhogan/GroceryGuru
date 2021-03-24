from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listItem_model import ListItem
from models.store_model import Store
from schemas.listItem_schema import listItem_schema
from schemas.store_schema import store_schema

listItem_api = Blueprint('listItem_api', __name__)

# Add an item # TODO - sort out autoincrement on the item_id
@listItem_api.route('/item', methods=['POST'])
def add_item():
  item_id = request.json['item_id']
  list_id = request.json['list_id']
  store = request.json['store'] # Store must be added for user to add items to that store, so this works
  qty = request.json['qty']
  description = request.json['description']
  purchased = request.json['purchased']

  new_item = ListItem(item_id, list_id, store, qty, description, purchased)

  db.session.add(new_item)
  db.session.commit()

  return listItem_schema.jsonify(new_item)

# Get a list
@listItem_api.route('/list/<id>', methods=['GET'])
def get_items(id):
  list_items = ListItem.query.filter_by(list_id=id).all()
  return listItem_schema.jsonify(list_items, many=True)