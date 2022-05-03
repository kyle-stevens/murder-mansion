from flask import Flask, request
import json
import random
app = Flask(__name__)

servers = {}

#@app.route('/')
#def hello_world():
#    return 'Hello World'

@app.route('/join', methods=['POST'])
def join():
    print(request.data)
    new_user = json.loads(request.data)
    print(new_user)
    if new_user["server"] in servers.keys():
        servers[new_user["server"]].append(new_user["username"])
    else:
        return("Server not available")
    print(servers[new_user["server"]])
    return {"my": "login"}

@app.route('/host', methods=['POST'])
def host(): #need to handle a player overwriting other servers? make a request and randomly generate code instead(hash it)
    print(request.data)
    new_user = json.loads(request.data)
    print(new_user)
    server_name = random.randint(0,10)
    servers["AAAA"] = [new_user["username"]] #going to need to add another field to handle multiple servers
    print(servers[new_user["server"]])
    return {"server" : server_name}




if __name__ == '__main__':
    app.run()