from flask import Flask, request
import json
import random
import string
app = Flask(__name__)

servers = {"AAAAAA" : []}

#@app.route('/')
#def hello_world():
#    return 'Hello World'

@app.route('/join', methods=['POST'])
def join():
    new_user = json.loads(request.data)
    print(new_user)

    if new_user["server"] in servers.keys():
        servers[new_user["server"]].append(new_user["username"])
        return {"server users" : servers[new_user["server"]]}
    else:
        return {"status" : "no such server exists"}
    return {"status": "None"}

@app.route('/host', methods=['POST'])
def host():
    new_user = json.loads(request.data)
    print(new_user)

    if new_user["username"] in servers:
        return {"error" : "fatal flaw, user is already in a server room"}
    else:
        server = ''.join(random.choices(string.ascii_uppercase + string.digits, k = 6))
        servers[server] = [new_user["username"]]
        return {"server" : server}
    return {"server": "None"}

if __name__ == '__main__':
    app.run()