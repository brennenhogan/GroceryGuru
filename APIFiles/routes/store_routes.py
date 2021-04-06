from flask import request, jsonify, Blueprint
from models.base_model import db
from models.store_model import Store
from schemas.store_schema import store_schema
from sqlalchemy import exc

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
    return {"result": False}

  return {"result": True}