import pickle

class User:

    _username : str = ""
    _password : str = ""
    nickname : str = ""
    _is_alive : str = ""
    _position : str = ""
    _rotation : str = ""
    _animation : str = ""
    _model : str = ""
    _color : str = ""
    _hat : str = ""
    _body : str = ""


    def __init__(self):
        return

    def GetPassword(self):
        return(self._password)

    def GetUsername(self):
        return(self._username)
        return

    def SetUsername(self, username):
        self._username = username

    def SetPassword(self, password):
        self._password = password

    def Save(self, filename):
        with open(filename, 'wb') as file:
            pickle.dump(self, file)
        return

    def Load(self, filename):
        with open(filename, 'rb') as file:
            loaded_user = pickle.load(file)
        #Load all attributes
        self._username = loaded_user.GetUsername()
        self._password = loaded_user.GetPassword()
        self.nickname = loaded_user.nickname
        return

    def GetPlayerStatus(self):
        return {"player_name" : self.nickname, "player_status" : self._is_alive, "player_position" : self._position,
                "player_rotation" : self._rotation, "player_animation" : self._animation, "player_model" : self._model,
                "player_color" : self._color, "player_hat" : self._hat, "player_body" : self._body}
    def InitializePlayerStatus(self):
        return