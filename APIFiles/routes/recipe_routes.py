from flask import request, jsonify, Blueprint
from models.base_model import db
from models.recipeItem_model import RecipeItem
from models.recipe_model import Recipe
from models.store_model import Store
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
    print("INVALID REQUEST - No permissions")
    return {"result": False}

  stores = db.session.query(RecipeItem.store_id).filter(RecipeItem.recipe_id==id).distinct().all()
  distinct_store_ids = [store._asdict()['store_id'] for store in stores] # Get the ids of the stores for a list
  
  recipeFragments = []
  for store_id in distinct_store_ids:
    store = Store.query.filter(Store.store_id==store_id).one() # Store_ids are distinct

    store_items = RecipeItem.query.filter(RecipeItem.recipe_id==id).filter(RecipeItem.store_id==store_id).all()
    
    recipeFragment = {"name": store.get_name(), "store_id": store_id, "items": store_items}
    recipeFragments.append(recipeFragment)
  
  return completeRecipe_schema.jsonify(recipeFragments, many=True)
