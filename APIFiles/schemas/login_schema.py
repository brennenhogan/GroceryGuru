from schemas.base_schema import ma

# Login Schema
class LoginSchema(ma.Schema):
  class Meta:
    fields = ('id', 'name', 'password', "uuid")

# Init schema
login_schema = LoginSchema()