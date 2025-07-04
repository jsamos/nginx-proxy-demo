from flask import Flask, jsonify
import argparse

app = Flask(__name__)

@app.route('/')
def hello_world():
    return jsonify({'message': 'Hello World from API v1!'})

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'version': 'v1'})

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--port', type=int, default=5000, help='Port to run the server on')
    args = parser.parse_args()
    
    app.run(host='0.0.0.0', port=args.port, debug=True) 