from flask import Flask, request
import json
import random
import string
import os.path
from os import path
#import User class
from User import User

#Import Logging Library to Suppress Flask Messages while Debugging
import logging
log = logging.getLogger('werkzeug')
log.setLevel(logging.ERROR)

#CONSTANTS
USERACCOUNTS = './userAccounts/'


#Create Flask App
app = Flask(__name__)

#Initialize Server List - {'server_key' : User[]}
servers = {}

#Initialize Active Users Account - {'username' : User}
active_users = {}

#chat queue for server testing - [['username' , str]]
message_queue = []

#App route for logging into the server
@app.route('/login', methods=['Post'])
def login():
    login_request = json.loads(request.data)
    if path.exists(USERACCOUNTS + login_request['username']):
        login_attempt_user = User()
        login_attempt_user.Load(USERACCOUNTS+login_request['username'])
        if login_attempt_user.GetPassword() == login_request['password']:
            active_users[login_attempt_user.GetUsername()] = login_attempt_user
            print(active_users) #remove this after debugging
            return {"status" : "LOGIN_OK"}
        else:
            return {"status" : "LOGIN_WRONG_CREDS"}
    else:
        return {"status" : "LOGIN_USER_DNE"}

#App route for creation of new user account
@app.route('/register', methods=['Post'])
def register():
    register_request = json.loads(request.data)
    if path.exists(USERACCOUNTS + register_request['username']):
        return {"status" : "REGISTER_USER_EXISTS"}
    else:
        new_register_user = User()
        new_register_user.SetUsername(register_request['username'])
        new_register_user.SetPassword(register_request['password'])
        #new_register_user.nickname = register_request['nickname'] #deprecated for now
        new_register_user.Save(USERACCOUNTS + new_register_user.GetUsername())
        return {"status" : "REGISTER_ACCOUNT_CREATED"}

@app.route('/join_lobby', methods=['Post'])
def join_lobby():
    join_request = json.loads(request.data)
    if join_request['username'] in active_users.key() and active_users[join_request['username']] in servers:
        return {"join_status" : "FATAL_ERROR_USER_ALREADY_JOINED_SERVER"}
    elif join_request['server'] in servers.keys() and join_request['username'] in active_users.key():
        servers[join_request['server']].append(active_users[join_request['username']])
        return {"status" : "SERVER_JOINED"}
    else:
        return {"status" : "SERVER_DNE"}

@app.route('/host_lobby', methods=['Post'])
def host_lobby():
    server_key = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    while(server_key in servers.keys()):
        server_key = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    return {"status" : "ONLINE", "server_key" : server_key}

@app.route('/ready_up', methods=['Post'])
def ready_up():
    ready_up_request = json.loads(request.data)
    active_users[ready_up_request['username']].lobby_is_ready = not active_users[ready_up_request['username']].lobby_is_ready
    return {"status" : active_users[ready_up_request['username']].lobby_is_ready}

#for server testing
@app.route('/chat_test', methods=['Post'])
def chat_test():
    chat_request = json.loads(request.data)
    if chat_request['type'] == "send":
        print("MESSAGE WAS SENT BY USER")
        user = active_users[chat_request['username']]
        message_queue.append(user.GetUsername() + " : " +  chat_request['mesg'])
        return {'status' : "MESG_RECEIVED"}
    else:
        user = active_users[chat_request['username']]
        return_mesg = ""
        for mesg in message_queue:
            return_mesg += mesg + "\n"
        return {'status' : "MESG_UPDATE", 'mesg' : return_mesg, "list" : list(active_users.keys())}


if __name__ == '__main__':
    #app.run(host="0.0.0.0")
    app.run()
