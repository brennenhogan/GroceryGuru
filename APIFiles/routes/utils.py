from models.base_model import db
from models.list_model import List
from models.listItem_model import ListItem
from models.store_model import Store
from models.recipeStore_model import RecipeStore
from models.listOwnership_model import ListOwnership
from models.recipeItem_model import RecipeItem
from models.recipe_model import Recipe
from sqlalchemy import exc

def update_version(list_id):
  selectedList = List.query.filter(List.list_id==list_id).first() # Get the list from the DB
  selectedList.version = selectedList.version + 1 # update the version

  try:
    db.session.commit()
  except exc.SQLAlchemyError:
    print(exc.SQLAlchemyError)
    return False

  return True

def insert_default_data(uuid):
  default_lists = DummyList(["My First List", "Weekly Groceries"],
                            [
                              [Items("Martin's", ["Beef Patties", "Buns", "Fries", "Salad"])], 
                              [Items("Martin's", ["Chicken", "Onion", "Bell Pepper", "Fajita Seasoning"]), Items("Walmart", ["Ground Beef", "Sloppy Joe Sauce", "Buns", "Cheese"])]
                            ]
                           )
  
  for i in range(default_lists.get_list_count()):
    list_name = default_lists.get_list_name(i)

    db.session.add(list_name)
    db.session.flush() # Get the id from list_name
    new_owner = ListOwnership(uuid, list_name.list_id) # Update the ownership table with this new list so that the uuid owns it
    db.session.add(new_owner)

    items = default_lists.get_index(i)
    for item in items:
      store_name = item.store_name
      new_store = Store(store_name, list_name.list_id)
      db.session.add(new_store)

      db.session.flush() # Get the id from store_name

      items = item.items
      for item_name in items:
        new_item = ListItem(list_name.list_id, new_store.store_id, 1, item_name, 0)
        db.session.add(new_item)

  # Insert Recipes

  new_recipe = Recipe("Picnic", uuid)
  db.session.add(new_recipe)
  db.session.flush() # Get the id from new_recipe

  new_store = RecipeStore("Martin's", new_recipe.recipe_id)
  db.session.add(new_store)
  db.session.flush() # Get the id from new_recipe

  items = [RecipeItem(new_recipe.recipe_id, new_store.store_id, 6, "Hot Dogs"), RecipeItem(new_recipe.recipe_id, new_store.store_id, 6, "Buns"), 
           RecipeItem(new_recipe.recipe_id, new_store.store_id, 1, "Ketchup") , RecipeItem(new_recipe.recipe_id, new_store.store_id, 1, "Mustard"), 
           RecipeItem(new_recipe.recipe_id, new_store.store_id, 6, "Chips")]

  for item in items:
    db.session.add(item)

  db.session.commit()

class Items():
  def __init__(self, store_name, items):
    self.store_name = store_name
    self.items = items

class DummyList():
  def __init__(self, list_names, items):
    self.lists = []
    for list_name in list_names:
      self.lists.append(List(list_name, 0))
    
    self.items = items

  def get_list_name(self, index):
    return self.lists[index]

  def get_index(self, index):
    return self.items[index]

  def get_list_count(self):
    return len(self.lists)
