CREATE TABLE IF NOT EXISTS visits (
    id SERIAL PRIMARY KEY,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

    name = db.Column(db.String(120), nullable=False)
    species = db.Column(db.String(50), nullable=False)
    age = db.Column(db.Integer)
    description = db.Column(db.Text)
    image_filename = db.Column(db.String(120))
);
