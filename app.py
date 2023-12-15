from flask import Flask, render_template, json, redirect, request
import database.db_connector as db
import os

# Citation for the following functions:
# Date 10/30/2023
# All code is based on the CS 340 flask starter code
# Source URL: https://github.com/osu-cs340-ecampus/flask-starter-app/

# All of our methods/queries are in appmethods.py to condense the size of app.py
import appmethods as am

# Zedfin Group 8 Configuration

app = Flask(__name__)
db_connection = db.connect_to_database()


# Routes

@app.route('/', methods=["POST", "GET"])
def root():
    if request.method == "GET":
        return render_template("home.j2")

    if request.method == "POST":
        if request.form.get("Reset"):
            return (am.reset_database())


@app.route('/Agents', methods=["POST", "GET"])
def agents():
    if request.method == "GET":
        return (am.get_agents())

    # insert an agent into the Agents entity
    if request.method == "POST":
        # fire off if user presses the Add Agent button
        if request.form.get("Add_Agent"):
            return (am.add_agent())


@app.route('/delete_agent/<int:id>', methods=["POST", "GET"])
def delete_agent(id):
    if request.method == "GET":
        return (am.get_agent_delete(id))

    if request.method == "POST":
        return (am.delete_agent(id))


@app.route('/edit_agent/<int:id>', methods=["POST", "GET"])
def get_agent_edit(id):
    if request.method == "GET":
        return (am.get_agent_edit(id))

    if request.method == "POST":
        # fire off if user presses the Add Agent button
        if request.form.get("Edit_Agent"):
            return (am.edit_agent(id))


@app.route("/Customers", methods=["POST", "GET"])
def customers():
    if request.method == "GET":
        return (am.get_customers())

     # insert a customer into the Customers entity
    if request.method == "POST":
        if request.form.get("Add_Customer"):
            return (am.add_customer())


@app.route('/Listings', methods=["POST", "GET"])
def listing_details():
    if request.method == "GET":
        return (am.get_listings())

     # insert a customer into the Customers entity
    if request.method == "POST":
        if request.form.get("Add_Listing"):
            return (am.add_listing())


@app.route('/Properties', methods=["POST", "GET"])
def properties():
    if request.method == "GET":
        return (am.get_properties())

     # insert a new property into Properties entity
    if request.method == "POST":
        if request.form.get("Add_Property"):
            return (am.add_property())


@app.route('/Transactions', methods=["POST", "GET", "PUT"])
def property_transactions():
    if request.method == "GET":
        return (am.get_transactions())

    if request.method == "POST":
        # insert a new transaction into Transactions entity
        if request.form.get("Add_Transaction"):
            return (am.add_transaction())

    if request.method == "POST":
        # insert a new intersection into Intersections table
        if request.form.get("Add_Intersection"):
            return (am.add_intersection())


@app.route("/delete_intersection/<int:id>")
def delete_intersection(id):
    return (am.delete_intersection(id))


# Listener
if __name__ == "__main__":

    # Start the app on port 41102, it will be different once hosted
    app.run(port=41102, debug=True)
