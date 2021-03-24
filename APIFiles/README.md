GroceryGuru APIFiles

# Activate venv (use python3)
$ pipenv shell

If pipenv isn't found, do pip3 install pipenv.
It will install flask, flask-sqlalchemy, flask-marshmallow, and marshmallow-sqlalchemy.

# Create DB (if not already created)
$ python3
>> import app
>> app.create()
>> exit()

Currently if the DB already exists, you must delete the existing database and recreate using the steps above if the schema has changed

# Run Server (http://localhst:5000)
python app.py

SQLAlchemy will allow us to change the DB from sqlite to a cloud DB if needed