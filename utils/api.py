from flask import Flask, jsonify, Response
import os
import hashlib
import sys
import _api.api_variabels as api_var


api = Flask(__name__)



@api.route('/'+api_var.token_id, methods=['GET'])
def download_file():
    try:
        file_path = os.path.join(api_var.FOLDER_PATH, api_var.filename)
        if not os.path.exists(file_path):
            return jsonify({'error': 'File not found'}), 404
        
        def generate():
            with open(file_path, 'rb') as f:
                while chunk := f.read(8192):
                    yield chunk

        return Response(generate(), mimetype='application/octet-stream')
    except Exception as e:
        return jsonify({'error': str(e)}), 500




if __name__ == '__main__': api.run(debug=True, host='0.0.0.0', 
    port=api_var.port_local)

