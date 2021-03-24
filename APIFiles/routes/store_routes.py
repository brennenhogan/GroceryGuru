from flask import request, jsonify, Blueprint
from models.base_model import db
from models.store_model import Store
from schemas.store_schema import store_schema

store_api = Blueprint('store_api', __name__)

# Add a store
@store_api.route('/store', methods=['POST'])
def add_store():
  store_id = request.json['store_id']
  store_name = request.json['store_name']

  new_store = Store(store_id, store_name)

  db.session.add(new_store)
  db.session.commit()

  return store_schema.jsonify(new_store)