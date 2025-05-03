# For Testing


source .env
source $VENV_NAME/bin/activate

cd utils
gunicorn -w 4 -b 0.0.0.0:$PORT_LOCAL --no-sendfile -t 17280 api:api
#gunicorn -w 4 --timeout=300 -b 0.0.0.0:$PORT_LOCAL api:api
#gunicorn --workers=4 --timeout=300 -b 0.0.0.0:$PORT_LOCAL app:api 
