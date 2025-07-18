from . import db


class Pet(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    species = db.Column(db.String(50), nullable=False)
    age = db.Column(db.Integer)
    description = db.Column(db.Text)
    image_filename = db.Column(db.String(120))
