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

#Initialize Active Users Account
active_users = {}

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

@app.route('/join_lobby', methods=['Post'])
def join_lobby():
    join_request = json.loads(request.data)
    if join_request['username'] in active_users.key() and active_users[join_request['username']] in servers:
        return {"server_join_status" : "FATAL_ERROR_USER_ALREADY_JOINED_SERVER"}
    elif join_request['server'] in servers.keys() and join_request['username'] in active_users.key():
        servers[join_request['server']].append(active_users[join_request['username']])
        return {"server_join_status" : "SERVER_JOINED"}
    else:
        return {"server_join_status" : "SERVER_DNE"}

@app.route('/host_lobby', methods=['Post'])
def host_lobby():
    server_key = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    while(server_key in servers.keys()):
        server_key = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    return {"server_status" : "ONLINE", "server_key" : server_key}

@app.route('/ready_up', methods=['Post'])
def ready_up():
    ready_up_request = json.loads(request.data)
    active_users[ready_up_request['username']].lobby_is_ready = not active_users[ready_up_request['username']].lobby_is_ready
    return {"player_ready_status" : active_users[ready_up_request['username']].lobby_is_ready}

if __name__ == '__main__':
    #app.run(host="0.0.0.0")
    app.run()
