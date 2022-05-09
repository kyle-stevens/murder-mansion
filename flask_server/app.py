from flask import Flask, request
import json
import random
import string
import os.path
from os import path
#import User class
from User import User

#Import Logging Library to Suppress Flask Messages while Debugging
#import logging
#log = logging.getLogger('werkzeug')
#log.setLevel(logging.ERROR)

#CONSTANTS
USERACCOUNTS = './userAccounts/'


#Create Flask App
app = Flask(__name__)

#Initialize Server List
servers = {}

#Initialize Active Users Account - filepaths to stored user data
active_users = []

#App route for logging into the server
@app.route('/login', methods=['Post'])
def login():
    login_request = json.loads(request.data)
    if path.exists(USERACCOUNTS + login_request['username']):
        login_attempt_user = User()
        login_attempt_user.Load(USERACCOUNTS+login_request['username'])
        if login_attempt_user.GetPassword() == login_request['password']:
            active_users.append(login_attempt_user)
            print(active_users) #remove this after debugging
            return {"login_status" : "OK"}
        else:
            return {"login_status" : "WRONG_CREDS"}
    else:
        return {"login_status" : "USER_DNE"}

#App route for creation of new user account
@app.route('/register', methods=['Post'])
def register():
    register_request = json.loads(request.data)
    if path.exists(USERACCOUNTS + register_request['username']):
        return {"register_status" : "USER_EXISTS"}
    else:
        new_register_user = User()
        new_register_user.SetUsername(register_request['username'])
        new_register_user.SetPassword(register_request['password'])
        new_register_user.nickname = register_request['nickname']
        new_register_user.Save(USERACCOUNTS + new_register_user.GetUsername())
        return {"register_Status" : "ACCOUNT_CREATED"}


'''
@app.route('/join', methods=['POST'])
def join():
    new_user = json.loads(request.data)
    #print(new_user)

    if new_user["server"] in servers.keys():
        servers[new_user["server"]].append(new_user["username"])
        return {"server" : new_user["server"]}
    else:
        return {"status" : "no such server exists"}
    return {"status": "None"}

@app.route('/host', methods=['POST'])
def host():
    new_user = json.loads(request.data)
    #print(new_user)

    if new_user["username"] in servers:
        return {"error" : "fatal flaw, user is already in a server room"}
    else:
        server = ''.join(random.choices(string.ascii_uppercase + string.digits, k = 6))
        servers[server] = [new_user["username"]]
        return {"server" : server}
    return {"server": "None"}

@app.route('/update', methods=['POST'])
def update():
    #print(json.loads(request.data))
    #print(servers[json.loads(request.data)["server"]])
    print(request.remote_addr)
    return {"player_list" : servers[json.loads(request.data)["server"]]}
'''

if __name__ == '__main__':
    #app.run(host="0.0.0.0")
    app.run()