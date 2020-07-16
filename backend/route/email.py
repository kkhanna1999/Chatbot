from myapp import app
from model import *
from flask import Flask, request, jsonify
@app.route('/getmail', methods=['POST'])
def get_mail():
    email = request.json['email']
    new_email = Mail(email)
    db.session.add(new_email)
    db.session.commit()
    return jsonify({'message': 'success'})
