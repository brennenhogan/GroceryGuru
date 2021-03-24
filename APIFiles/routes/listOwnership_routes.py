from flask import request, jsonify, Blueprint
from models.base_model import db
from models.listOwnership_model import ListOwnership
from models.list_model import List
from schemas.listOwnership_schema import listOwnership_schema
from schemas.list_schema import list_schema

listOwnership_api = Blueprint('listOwnership_api', __name__)

# Add a new list (or share a list to another user)
@listOwnership_api.route('/owner', methods=['POST'])
def add_owner():
  uuid = request.json['uuid']
  list_id = request.json['list_id']

  new_owner = ListOwnership(uuid, list_id)

  db.session.add(new_owner)
  db.session.commit()

  return listOwnership_schema.jsonify(new_owner)

# See all lists for a user (List.name, List.old, ListOwnership.list_id)
@listOwnership_api.route('/owner/<user_uuid>', methods=['GET'])
def get_listids(user_uuid):
  lists = ListOwnership.query\
    .join(List, List.list_id == ListOwnership.list_id).\
    filter(ListOwnership.uuid==user_uuid).all()
  print(lists)
  return listOwnership_schema.jsonify(lists, many=True)