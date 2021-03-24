from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listOwnership_model import ListOwnership
from schemas.listOwnership_schema import listOwnership_schema

listOwnership_api = Blueprint('listOwnership_api', __name__)

# Add a new list (or share a list to another user)
@listOwnership_api.route('/owner', methods=['POST'])
def add_owner():
  user_id = request.json['user_id']
  list_id = request.json['list_id']

  new_owner = ListOwnership(user_id, list_id)

  db.session.add(new_owner)
  db.session.commit()

  return listOwnership_schema.jsonify(new_owner)