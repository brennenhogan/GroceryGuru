from models.base_model import db
from models.list_model import List
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