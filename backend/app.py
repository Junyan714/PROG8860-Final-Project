from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/greeting', methods=['GET'])
def greeting():
    return jsonify({"message": "Hello! This is Junyan Zhang's final project. Student id is 8903870"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
