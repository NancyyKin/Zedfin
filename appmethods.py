from flask import Flask, render_template, json, redirect, request
import database.db_connector as db
import os

# Citation for the following functions:
# Date 10/30/2023
# All code is based on the CS 340 flask starter code
# Source URL: https://github.com/osu-cs340-ecampus/flask-starter-app/

db_connection = db.connect_to_database()


# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________


# Agents
# Populates the Agents table
def get_agents():
    query = "SELECT `agent_id` AS `Agent ID`, `agent_first_name` AS `First Name`, `agent_last_name` AS `Last Name`, `agent_phone` AS `Phone Number`, `agent_email` AS `Email` FROM Agents;"
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("agents.j2", Agents=results)


# Adds an Agent
def add_agent():
    # grab user form inputs
    agent_first_name = request.form["agent_first_name"]
    agent_last_name = request.form["agent_last_name"]
    agent_phone = request.form["agent_phone"]
    agent_email = request.form["agent_email"]

   # null mandatory fields
    if agent_first_name == "" or agent_last_name == "" or agent_phone == "" or agent_email == "":
        return redirect("/Agents#error")

    # no null inputs
    query = "INSERT INTO `Agents` (`agent_first_name`, `agent_last_name`, `agent_phone`, `agent_email`) VALUES (%s, %s, %s, %s)"
    cursor = db.execute_query(
        db_connection=db_connection, query=query, query_params=(agent_first_name, agent_last_name, agent_phone, agent_email,))
    # redirect back to agents page
    return redirect("/Agents")


# get values to prompt user if they really want to delete an agent
def get_agent_delete(id):
    query = "SELECT agent_id, agent_first_name , agent_last_name FROM Agents WHERE agent_id = '%s';"
    cursor = db.execute_query(
        db_connection=db_connection, query=query, query_params=(id,))
    results = cursor.fetchall()
    return render_template("agent_delete.j2", Agent=results)


# deletes the agent with the given id#
def delete_agent(id):
    # mySQL query to delete the person with our passed id
    query = "DELETE FROM Agents WHERE agent_id = '%s';"
    cursor = db.execute_query(
        db_connection=db_connection, query=query, query_params=(id,))
    # redirect back to agents page
    return redirect("/Agents")


# get agent information for editing page
def get_agent_edit(id):
    query = "SELECT * FROM Agents WHERE agent_id = '%s';"
    cursor = db.execute_query(
        db_connection=db_connection, query=query, query_params=(id,))
    results = cursor.fetchall()
    return render_template("agent_edit.j2", Agent=results)


# sends update agent request to the server
def edit_agent(id):
    # grab user form inputs
    agent_id = request.form["agent_id"]
    agent_first_name = request.form["agent_first_name"]
    agent_last_name = request.form["agent_last_name"]
    agent_phone = request.form["agent_phone"]
    agent_email = request.form["agent_email"]

    # mySQL query to edit the person with our passed id
    query = "UPDATE Agents SET Agents.agent_phone = %s, Agents.agent_first_name = %s, Agents.agent_last_name = %s, Agents.agent_email = %s WHERE Agents.agent_id = %s;"
    # UPDATE Agents SET Agents.agent_phone = "1238675309" WHERE Agents.agent_id = 1;
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        agent_phone, agent_first_name, agent_last_name, agent_email, agent_id,))
    # UPDATE Agents SET Agents.agent_phone = "1238675309" WHERE Agents.agent_id = 1;

    # redirect back to agents page
    return redirect("/Agents")


# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________

# Customers

# ** Citation for the following CASE statment, Date 11/29/2023, a tip from Zachary Bartel
# Based on: https://www.sqlshack.com/case-statement-in-sql/ **

# Populates the Customers table
def get_customers():
    query = "SELECT `customer_id` AS `Customer ID`, `customer_first_name` AS `First Name`, `Customer_last_name` AS `Last Name`, `Customer_phone` AS `Phone Number`, `customer_email` AS `Email`, CASE WHEN `buying_property` = 1 THEN 'Yes' ELSE 'No' END AS `Is buying property?`, FORMAT(`buying_budget`, N'NO') AS `Buying Budget ($)`, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Buying Agent` FROM Customers LEFT JOIN Agents ON Customers.buying_agent = Agents.agent_id;"
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    query2 = "SELECT Agents.agent_id AS agent_id, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent Name`FROM Agents;"
    cursor = db.execute_query(db_connection=db_connection, query=query2)
    results2 = cursor.fetchall()

    return render_template("customers.j2", Customers=results, Agents=results2)


# Adds a new Customer to the table
def add_customer():
    # grab user form inputs
    customer_first_name = request.form["customer_first_name"]
    customer_last_name = request.form["customer_last_name"]
    customer_phone = request.form["customer_phone"]
    customer_email = request.form["customer_email"]
    buying_property = request.form["buying_property"]
    buying_budget = request.form["buying_budget"]
    buying_agent = request.form["buying_agent"]

    # null mandatory fields
    if customer_first_name == '' or customer_last_name == '' or customer_email == "":
        return redirect("/Customers#error")

    # no null inputs
    query = "INSERT INTO Customers (customer_first_name, customer_last_name, customer_phone, customer_email, buying_property, buying_budget, buying_agent) VALUES (%s, %s, %s, %s, %s, %s, (SELECT agent_id FROM Agents WHERE agent_id = %s))"
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        customer_first_name, customer_last_name, customer_phone, customer_email, buying_property, buying_budget, buying_agent,))
    return redirect("/Customers")

# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________

# Listing_Details


def get_listings():
    # Populates the Listing Details table
    query = "SELECT `listing_id` AS `Listing ID`, `listing_name` AS `Listing Name`, Properties.property_name AS `Property Name`, `listing_date` AS `Listing Date`, FORMAT(`listing_price`, N'NO') AS `Listing Price`, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent`, CONCAT(Customers.customer_last_name,', ', Customers.customer_first_name) AS `Seller`, CASE WHEN `active_listing` = 1 THEN 'Yes' ELSE 'No' END AS `Active Listing?` FROM Listing_Details LEFT JOIN Properties ON Listing_Details.property_id = Properties.property_id LEFT JOIN Agents ON Listing_Details.selling_agent_id = Agents.agent_id LEFT JOIN Customers ON Listing_Details.selling_customer_id = Customers.customer_id ORDER BY `Listing ID` ASC;"
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()

    # Populates the Property Names dropdown
    query2 = "SELECT Properties.property_id AS property_id, Properties.property_name AS `Property Name` FROM Properties;"
    cursor = db.execute_query(db_connection=db_connection, query=query2)
    results2 = cursor.fetchall()

    # Populates the Agent Names dropdown
    query3 = "SELECT Agents.agent_id AS agent_id, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent Name`FROM Agents;"
    cursor = db.execute_query(db_connection=db_connection, query=query3)
    results3 = cursor.fetchall()

    # Populates the Customers Names dropdown
    query4 = "SELECT Customers.customer_id AS customer_id, CONCAT(Customers.customer_last_name,', ', Customers.customer_first_name) AS `Customer Name` FROM Customers;"
    cursor = db.execute_query(db_connection=db_connection, query=query4)
    results4 = cursor.fetchall()

    return render_template("listing_details.j2", Listing_Details=results, Properties=results2, Agents=results3, Customers=results4)


# Adds a new listing
def add_listing():
    listing_name = request.form["listing_name"]
    property_id = request.form["property_id"]
    listing_date = request.form["listing_date"]
    listing_price = request.form["listing_price"]
    selling_agent_id = request.form["selling_agent_id"]
    selling_customer_id = request.form["selling_customer_id"]
    active_listing = request.form["active_listing"]

    query = "INSERT INTO Listing_Details (listing_name, property_id, listing_date, listing_price, selling_agent_id, selling_customer_id, active_listing) VALUES (%s, (SELECT property_id FROM Properties WHERE property_id = %s), %s, %s, (SELECT agent_id FROM Agents WHERE agent_id = %s), (SELECT customer_id FROM Customers WHERE customer_id = %s), %s)"
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        listing_name, property_id, listing_date, listing_price, selling_agent_id, selling_customer_id, active_listing,))

    return redirect("/Listings")

# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________

# Properties

# Populates the Properties table


def get_properties():
    query = "SELECT `property_id` AS `Property ID`, `property_name` AS `Property Name`, `no_of_rooms` AS `# Bedrooms`, `no_of_bathrooms` AS `# Bathrooms`, `sq_footage` AS `Sq Footage`, CASE WHEN `garage` = 1 THEN 'Yes' ELSE 'No' END AS `Has Garage?` FROM Properties;"
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()
    return render_template("properties.j2", Properties=results)

# Adds a new property


def add_property():
    # grab user form inputs
    property_name = request.form["property_name"]
    no_of_rooms = request.form["no_of_rooms"]
    no_of_bathrooms = request.form["no_of_bathrooms"]
    sq_footage = request.form["sq_footage"]
    garage = request.form["garage"]

    # null mandatory fields
    if property_name == '' or no_of_rooms == '' or no_of_bathrooms == "" or sq_footage == '':
        return redirect("/Properties#error")

    query = "INSERT INTO Properties (property_name, no_of_rooms, no_of_bathrooms, sq_footage, garage) VALUES (%s, %s, %s, %s, %s)"
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        (property_name, no_of_rooms, no_of_bathrooms, sq_footage, garage,)))

    return redirect("/Properties")


# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________

# Transactions Page

def get_transactions():
    # Populates the Transaction table with M:N agents references
    query = "SELECT Property_Transactions.transaction_id AS `Transaction ID`, Property_Transactions.transaction_date AS `Transaction Date`, FORMAT(Property_Transactions.contract_price, N'NO') AS `Contract Price`, Listing_Details.listing_name AS `Listing Name`, GROUP_CONCAT(' ', Agents.agent_first_name, ' ', Agents.agent_last_name ) AS `Agents` FROM Property_Transactions LEFT JOIN Property_Transactions_has_Agents ON Property_Transactions.transaction_id = Property_Transactions_has_Agents.transaction_id JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id LEFT JOIN Agents ON Property_Transactions_has_Agents.agent_id = Agents.agent_id GROUP BY `Listing Name` ORDER BY Property_Transactions.transaction_id;"
    cursor = db.execute_query(db_connection=db_connection, query=query)
    results = cursor.fetchall()

    # Populates the intersection table (M:N)
    query2 = "SELECT `intersection_id` AS `Intersection ID`, Listing_Details.listing_name AS `Listing Name`, CASE WHEN Agents.agent_id is NULL THEN 'Null' ELSE CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) END AS `Agent`FROM (((Property_Transactions_has_Agents INNER JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id) INNER JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id) LEFT JOIN Agents ON Property_Transactions_has_Agents.agent_id = Agents.agent_id) ORDER BY `Listing Name` ASC;"
    cursor = db.execute_query(db_connection=db_connection, query=query2)
    results2 = cursor.fetchall()

    # Agent names dropdown
    query3 = "SELECT Agents.agent_id AS agent_id, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent Name`FROM Agents;"
    cursor = db.execute_query(db_connection=db_connection, query=query3)
    results3 = cursor.fetchall()

    # Listings Names dropdown (selects listings that are NOT in the intersection table)
    query4 = "SELECT Property_Transactions.transaction_id, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Listing_Details LEFT JOIN Property_Transactions ON Property_Transactions.listing_id = Listing_Details.listing_id AND Listing_Details.listing_id WHERE Property_Transactions.transaction_id IS NULL;"
    cursor = db.execute_query(db_connection=db_connection, query=query4)
    results4 = cursor.fetchall()

    # Intersection's Listings Names dropdown (selects listings that are in the intersection table)
    query5 = "SELECT DISTINCT Property_Transactions.transaction_id AS `Transaction ID`, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Property_Transactions_has_Agents RIGHT JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id;"
    cursor = db.execute_query(db_connection=db_connection, query=query5)
    results5 = cursor.fetchall()
    return render_template("transactions.j2", Property_Transactions=results, Property_Transactions_has_Agents=results2, Agents=results3, Listing_Details=results4, Intersections=results5)


# Adds a new Transaction Entry
def add_transaction():
    # grab user form inputs
    transaction_date = request.form["transaction_date"]
    contract_price = request.form["contract_price"]
    listing_id = request.form["listing_id"]

    query = "INSERT INTO Property_Transactions (transaction_date, contract_price, listing_id) VALUES (%s, %s, %s)"
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        transaction_date, contract_price, listing_id,))

    return redirect("/Transactions")


# Adds a new Intersection Entry
def add_intersection():
    # grab user form inputs
    listing_id = request.form["listing_id"]
    agent_id = request.form["agent_id"]

    query = "INSERT INTO Property_Transactions_has_Agents (transaction_id, agent_id) VALUES ((SELECT transaction_id FROM Property_Transactions WHERE listing_id = %s), %s)"
    cursor = db.execute_query(db_connection=db_connection, query=query, query_params=(
        listing_id, agent_id,))

    return redirect("/Transactions")


# Deletes an Intersection Entry from Table
def delete_intersection(id):
    # mySQL query to delete the person with our passed id
    query = "DELETE FROM Property_Transactions_has_Agents WHERE intersection_id = '%s';"
    cursor = db.execute_query(
        db_connection=db_connection, query=query, query_params=(id,))
    # redirect back to agents page
    return redirect("/Transactions#browse2")


# _________________________________________________________________________________________________________
# _________________________________________________________________________________________________________


def reset_database():
    query1 = "SET FOREIGN_KEY_CHECKS=0;"
    cursor = db.execute_query(db_connection=db_connection, query=query1)

    query2 = "DROP TABLE `Agents`, `Customers`, `Listing_Details`, `Properties`, `Property_Transactions`, `Property_Transactions_has_Agents`;"
    db.execute_query(db_connection=db_connection, query=query2)

    db.exec_sql_file(cursor=cursor, sql_file="database/DDL.sql")

    return redirect("/")
