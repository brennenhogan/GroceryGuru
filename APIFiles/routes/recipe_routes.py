from flask import request, jsonify, Blueprint
from models.base_model import db
from models.recipeItem_model import RecipeItem
from models.recipe_model import Recipe
from models.recipeStore_model import RecipeStore
from schemas.recipeItem_schema import recipeItem_schema
from schemas.recipe_schema import recipe_schema
from schemas.completeRecipe_schema import completeRecipe_schema
from sqlalchemy import exc

recipe_api = Blueprint('recipe_api', __name__)

# Add a recipe
@recipe_api.route('/recipe/create', methods=['POST'])
def add_recipe():
  uuid = request.json['uuid']
  name = request.json['name']

  new_recipe = Recipe(name, uuid)
 
  db.session.add(new_recipe)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Delete a recipe
@recipe_api.route('/recipe/delete', methods=['POST'])
def delete_recipe():
  recipe_id = request.json['recipe_id']
 
  recipe = Recipe.query.filter(Recipe.recipe_id==recipe_id).first() # Get the item from the DB
  db.session.delete(recipe)

  stores = RecipeStore.query.filter(RecipeStore.recipe_id==recipe_id).all()
  items = RecipeItem.query.filter(RecipeItem.recipe_id==recipe_id).all()
  for store in stores:
    db.session.delete(store)
  for item in items:
    db.session.delete(item)
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Updates the name of a recipe
@recipe_api.route('/recipe/update', methods=['POST'])
def update_recipe():
  name = request.json['name']
  recipe_id = request.json['recipe_id']
 
  recipe = Recipe.query.filter(Recipe.recipe_id==recipe_id).first() # Get the item from the DB
  recipe.name = name
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Get all recipes
@recipe_api.route('/recipe/<user_uuid>', methods=['Get'])
def get_recipes(user_uuid):
  recipes = Recipe.query.filter(Recipe.uuid==user_uuid).all()

  all_recipes = []
  for recipe in recipes:
    count = RecipeItem.query.filter(RecipeItem.recipe_id==recipe.get_id()).count()
    all_recipes.append({"recipe_id": recipe.get_id(), "name": recipe.get_name(), "recipe_qty": count})

  return recipe_schema.jsonify(all_recipes, many=True)

# Add an item to a recipe
@recipe_api.route('/recipe/add', methods=['POST'])
def add_recipeItem():
  recipe_id = request.json['recipe_id']
  store_id = request.json['store_id']
  qty = request.json['qty']
  description = request.json['description']

  new_recipeItem = RecipeItem(recipe_id, store_id, qty, description)
 
  db.session.add(new_recipeItem)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Update the quantity of an item
@recipe_api.route('/recipe/qty', methods=['POST'])
def update_qty():
  item_id = request.json['item_id']
  qty = request.json['qty']
 
  item = RecipeItem.query.filter(RecipeItem.item_id==item_id).first() # Get the item from the DB
  item.qty = qty # update the quantity

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Delete an item
@recipe_api.route('/recipeitem/delete', methods=['POST'])
def delete_item():
  item_id = request.json['item_id']
 
  item = RecipeItem.query.filter(RecipeItem.item_id==item_id).first() # Get the item from the DB
  db.session.delete(item)
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Get a recipe by ID
@recipe_api.route('/recipe/<id>/<user_uuid>', methods=['GET'])
def get_recipe(id, user_uuid):
  owner = Recipe.query.filter(Recipe.uuid==user_uuid).filter(Recipe.recipe_id==id).all()
  
  if not owner:
    return {"result": False}

  stores = RecipeStore.query.filter(RecipeStore.recipe_id==id).distinct().all()
  recipeFragments = []
  for store_obj in stores:
    store_id = store_obj.get_id()

    store_items = RecipeItem.query.filter(RecipeItem.recipe_id==id).filter(RecipeItem.store_id==store_id).all()
    
    recipeFragment = {"name": store_obj.get_name(), "store_id": store_id, "items": store_items}
    recipeFragments.append(recipeFragment)
  
  return completeRecipe_schema.jsonify(recipeFragments, many=True)

# Add a store
@recipe_api.route('/recipe/store', methods=['POST'])
def add_store():
  store_name = request.json['store_name']
  recipe_id = request.json['recipe_id']

  new_store = RecipeStore(store_name, recipe_id)

  db.session.add(new_store)
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Edit a store
@recipe_api.route('/recipe/store/name', methods=['POST'])
def edit_store():
  store_name = request.json['store_name']
  store_id = request.json['store_id']
  recipe_id = request.json['recipe_id']
 
  selected_store = RecipeStore.query.filter(RecipeStore.store_id==store_id).filter(RecipeStore.recipe_id==recipe_id).first() # Get the list from the DB
  selected_store.store_name = store_name
  
  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}

# Delete a store (and all of its items!)
@recipe_api.route('/recipe/store/delete', methods=['POST'])
def delete_store():
  store_id = request.json['store_id']
  recipe_id = request.json['recipe_id']
  uuid = request.json["uuid"]

  owner = db.session.query(Recipe).filter(Recipe.uuid==uuid).filter(Recipe.recipe_id==recipe_id).all()
  
  if not owner: # Make sure they have permission to delete this store
    return {"result": False}

  items = RecipeItem.query.filter(RecipeItem.store_id==store_id).all() # Get all items for the list with store_id == store_id

  for item in items:
    db.session.delete(item)

  store = RecipeStore.query.filter(RecipeStore.store_id==store_id).one()
  db.session.delete(store)

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return {"result": False}

  return {"result": True}
