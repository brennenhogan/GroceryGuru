from flask import Flask
from routes.product_routes import product_api
from routes.login_routes import login_api
from routes.listItem_routes import listItem_api
from routes.store_routes import store_api
from routes.listOwnership_routes import listOwnership_api
from routes.list_routes import list_api
from models.base_model import db
from schemas.base_schema import ma
import os

# Init app
app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))

# Database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'databases/main.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
#app.config['SQLALCHEMY_ECHO'] = True # See raw SQL queries here

db.init_app(app)
ma.init_app(app)

app.register_blueprint(product_api)
app.register_blueprint(login_api)
app.register_blueprint(listItem_api)
app.register_blueprint(store_api)
app.register_blueprint(listOwnership_api)
app.register_blueprint(list_api)

# Create DB
def create():
  db.create_all(app=app)

# Run Server
if __name__ == '__main__':
  app.run(debug=True)
