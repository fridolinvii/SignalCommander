from flask import Flask, jsonify, send_file
import os
import hashlib
import sys
import _api.api_variabels as api_var


api = Flask(__name__)

@api.route('/' + api_var.token_id, methods=['GET'])
def download_file():
    try:
        file_path = os.path.join(api_var.FOLDER_PATH, api_var.filename)
        if not os.path.exists(file_path):
            return jsonify({'error': 'File not found'}), 404

        return send_file(
            file_path,
            as_attachment=True,
            download_name="download.7z",
            mimetype="application/octet-stream",
            conditional=False
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500



if __name__ == '__main__': api.run(debug=False, host='0.0.0.0', 
    port=api_var.port_local)

