import os
from flask import request, redirect, render_template, url_for, flash
from werkzeug.utils import secure_filename
from . import db
from .models import Pet

from flask import current_app as app


@app.route("/")
def index():
    pets = Pet.query.all()
    return render_template("index.html", pets=pets)


@app.route("/add", methods=["GET", "POST"])
def add_pet():
    if request.method == "POST":
        name = request.form["name"]
        species = request.form["species"]
        age = request.form.get("age", type=int)
        description = request.form["description"]
        image = request.files.get("image")

        filename = None
        if image and image.filename:
            filename = secure_filename(image.filename)
            image.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

        new_pet = Pet(
            name=name,
            species=species,
            age=age,
            description=description,
            image_filename=filename,
        )
        db.session.add(new_pet)
        db.session.commit()
        return redirect(url_for("index"))

    return render_template("add.html")


@app.route('/edit/<int:pet_id>', methods=['GET', 'POST'])
def edit_pet(pet_id):
    pet = Pet.query.get_or_404(pet_id)

    if request.method == 'POST':
        pet.name = request.form['name']
        pet.species = request.form['species']
        pet.age = request.form['age']
        pet.description = request.form['description']

        image = request.files.get('image')
        if image and image.filename:
            upload_folder = os.path.join(
                os.path.dirname(__file__), 'static/uploads')
            os.makedirs(upload_folder, exist_ok=True)
            image_path = os.path.join(upload_folder, image.filename)
            image.save(image_path)
            pet.image_filename = image.filename

        db.session.commit()
        flash('Данные питомца обновлены')
        return redirect(url_for('index'))

    return render_template('edit.html', pet=pet)


@app.route("/delete/<int:pet_id>")
def delete_pet(pet_id):
    pet = Pet.query.get_or_404(pet_id)
    if pet.image_filename:
        image_path = os.path.join(
            app.config['UPLOAD_FOLDER'], pet.image_filename)
        if os.path.exists(image_path):
            os.remove(image_path)
    db.session.delete(pet)
    db.session.commit()
    return redirect(url_for("index"))
