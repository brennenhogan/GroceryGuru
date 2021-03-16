from flask import Flask
from models.product_model import product_api
from models.login_model import login_api
from models.base_model import db, ma
import os

# Init app
app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))

# Database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'databases/main.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
ma.init_app(app)

app.register_blueprint(product_api)
app.register_blueprint(login_api)

# Create DB
def create():
  db.create_all(app=app)

# Run Server
if __name__ == '__main__':
  app.run(debug=True)
