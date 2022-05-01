from flask import Flask, request
import json
app = Flask(__name__)

users = {}

@app.route('/')
def hello_world():
    return 'Hello World'

@app.route('/goodbye')
def good_bye():
    return 'Goodbye'

@app.route('/login', methods=['POST'])
def login():
    print(request.data)
    return {"my" : "login"}

#not sure if I want this setup quite yet
@app.route('/register', methods=['POST'])
def register():
    print(request.data)
    new_user = json.loads(request.data)
    print(new_user)
    users[new_user["username"]] = new_user["password"]
    print(users)
    return {"my" : "login"}


if __name__ == '__main__':
    app.run()