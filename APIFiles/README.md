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

AWS INSTRUCTIONS 
How to run:
export FLASK_ENV=production
export FLASK_APP="wsgi.py"
nohup gunicorn -w 3 -b 0.0.0.0:8080 wsgi:app 2>&1 &

We use 3 workers because we have 1 CPU core (2 workers per core) and 1 extra (recommended)

Old way to run:
nohup python3 app.py 2>&1 &
