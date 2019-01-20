from flask import Flask
from flask_restful import Resource, Api, reqparse

import sqlite3
import requests

parser = reqparse.RequestParser()
parser.add_argument('user_id')

            
app = Flask(__name__)
api = Api(app)

class Users(Resource):
    def get(self):
        conn = sqlite3.connect(DATABASE_FILE)
        c = conn.cursor()
        users = c.execute("SELECT * FROM user ORDER BY id")
        ret = [{ "id": user[0], "name": user[1], "username": user[2], "email": user[3]} for user in users]
        conn.close()
        return ret

class UserDetails(Resource):
    def get(self):
        conn = sqlite3.connect(DATABASE_FILE)
        c = conn.cursor()
        args = parser.parse_args()
        c.execute("SELECT * FROM user WHERE id=?", args["user_id"])
        user = c.fetchone()
        ret = { "id": user[0], "name": user[1], "username": user[2], "email": user[3] }
        conn.close()
        return ret

api.add_resource(Users, '/app/rest/getUsers')
api.add_resource(UserDetails, '/app/rest/getUserDetails')

if __name__ == '__main__':
    DATABASE_FILE = 'membership.db' #TODO a better way to share this variable

    conn = sqlite3.connect(DATABASE_FILE)
    c = conn.cursor()
    c.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='user'")
    if len(c.fetchall()) == 0:
        c.execute(
            """
            CREATE TABLE user (
                id INTEGER PRIMARY KEY NOT NULL,
                name TEXT NOT NULL,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL
            )
            """
        )
        users = requests.get(url = 'http://jsonplaceholder.typicode.com/users').json()
        for user in users:
            c.execute(
                    'INSERT INTO user VALUES (?, ?, ?, ?)',
                    (user["id"], user["name"], user["username"], user["email"])
            )
        conn.commit()
        conn.close()

    app.run()
