from flask import Flask, jsonify, send_from_directory
import os
import hashlib
import sys
import _api.api_variabels as api_var


api = Flask(__name__)



@api.route('/'+api_var.token_id, methods=['GET'])
def download_file():
    try:
        # Check if the file exists in the folder
        if api_var.filename not in os.listdir(api_var.FOLDER_PATH):
            return jsonify({'error': 'File not found'}), 404
        # Send the file from the directory
        return send_from_directory(api_var.FOLDER_PATH, api_var.filename, as_attachment=True)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
        
if __name__ == '__main__':
    api.run(debug=False, host='0.0.0.0', port=api_var.port_local)

