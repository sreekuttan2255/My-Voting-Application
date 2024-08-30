from flask import Flask, render_template, request, make_response, g
import os
import socket
import psycopg2
import random
import logging

option_a = os.getenv('OPTION_A', "Cats")
option_b = os.getenv('OPTION_B', "Dogs")
hostname = socket.gethostname()

app = Flask(__name__)

gunicorn_error_logger = logging.getLogger('gunicorn.error')
app.logger.handlers.extend(gunicorn_error_logger.handlers)
app.logger.setLevel(logging.INFO)

def get_db():
    if not hasattr(g, 'postgres_db'):
        g.postgres_db = psycopg2.connect(
            host=os.getenv("POSTGRES_HOST", "db"),
            database=os.getenv("POSTGRES_DB", "db"),
            user=os.getenv("POSTGRES_USER", "postgres"),
            password=os.getenv("POSTGRES_PASSWORD", "postgres")
        )
    return g.postgres_db

@app.teardown_appcontext
def close_db(exception):
    db = g.pop('postgres_db', None)
    if db is not None:
        db.close()

@app.route("/", methods=['POST', 'GET'])
def hello():
    voter_id = request.cookies.get('voter_id')
    if not voter_id:
        voter_id = hex(random.getrandbits(64))[2:-1]

    vote = None

    if request.method == 'POST':
        vote = request.form['vote']
        app.logger.info('Received vote for %s', vote)

        try:
            db = get_db()
            cursor = db.cursor()
            app.logger.info('Inserting into table with vote: %s and voter_id: %s', vote, voter_id)
            cursor.execute(
                "INSERT INTO voting (voter_id, vote) VALUES (%s, %s)",
                (vote, voter_id)
            )
            db.commit()
            cursor.close()
        except Exception as e:
            app.logger.error('Failed to save vote: %s', e)
            db.rollback()
            # Optionally, give feedback to the user if there's an error
            return "An error occurred while saving your vote.", 500

    resp = make_response(render_template(
        'index.html',
        option_a=option_a,
        option_b=option_b,
        hostname=hostname,
        vote=vote,
    ))
    resp.set_cookie('voter_id', voter_id)
    return resp

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80, debug=True, threaded=True)