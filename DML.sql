-- CS 340 - Introduction to Databases
-- Group 8 - Zedfin
-- Project Step 2

-- Team Members: Corie Gulik & Nancy Yang

-- These are some Database Manipulation queries for a partially implemented Project Website 
-- using the Zedfin database.

-- All code is based on CS340 starter code, adapted from https://github.com/osu-cs340-ecampus/flask-starter-app/tree/master 
-- retrieved on October 30, 2023 

-- --------------------------------------------------------------------------------

-- Agents Entity

-- get all the Agent's information
SELECT `agent_id` AS `Agent ID`, `agent_first_name` AS `First Name`, `agent_last_name` AS `Last Name`,
 `agent_phone` AS `Phone Number`, `agent_email` AS `Email` FROM Agents;
    
-- add a new Agent
INSERT INTO Agents (agent_first_name, agent_last_name, agent_phone, agent_email) 
VALUES (:agent_first_nameInput, :agent_last_nameInput, :agent_phoneInput, :agent_emailInput)

-- select an Agent to be edited
SELECT * FROM Agents WHERE agent_id = '%s'

-- update an Agents's data based on submission of the Update Agent form 
UPDATE Agents SET agent_first_name = :agent_first_nameInput, agent_last_name= :agent_last_nameInput, 
agent_phone = :agent_phoneInput, agent_email= :agent_emailInput WHERE agent_id= :agent_id_from_the_update_form

-- select an Agent to be deleted
SELECT agent_id, agent_first_name , agent_last_name FROM Agents WHERE agent_id = '%s'

-- delete an Agent
DELETE FROM Agents WHERE agent_id = :agent_id_selected_from_agent_page


-- --------------------------------------------------------------------------------

-- Customers Entity

-- get all the Customer's information
SELECT `customer_id` AS `Customer ID`, `customer_first_name` AS `First Name`, `Customer_last_name` AS `Last Name`, 
`Customer_phone` AS `Phone Number`, `customer_email` AS `Email`, CASE WHEN `buying_property` = 1 THEN 'Yes' ELSE 'No' END AS `Is buying property?`, 
FORMAT(`buying_budget`, N'NO') AS `Buying Budget ($)`, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Buying Agent` 
FROM Customers LEFT JOIN Agents ON Customers.buying_agent = Agents.agent_id;
    
-- add a new Customer
INSERT INTO Customers (customer_first_name, customer_last_name, customer_phone, customer_email, buying_property, buying_budget, buying_agent) 
VALUES (:customer_first_nameInput, :customer_last_nameInput, :customer_phoneInput, :customer_emailInput,
 :buying_property_from_dropdown_Input, :buying_budgetInput, :buying_agent_from_dropdown_Input)


-- --------------------------------------------------------------------------------

-- Properties Entity

-- getting all of the property details
SELECT `property_id` AS `Property ID`, `property_name` AS `Property Name`, `no_of_rooms` AS `# Bedrooms`, 
`no_of_bathrooms` AS `# Bathrooms`, `sq_footage` AS `Sq Footage`, CASE WHEN `garage` = 1 THEN 'Yes' ELSE 'No' END AS `Has Garage?` 
FROM Properties;
    
-- add a new Property
INSERT INTO Properties (property_name, no_of_rooms, no_of_bathrooms, sq_footage, garage) 
VALUES (:property_nameInput, :no_of_roomsInput, :no_of_bathrooms_phoneInput, :sq_footageInput, :garage_from_dropdown_Input)


-- --------------------------------------------------------------------------------

-- Listing Details Entity

-- ** Citation for the following SELECT number formatting, Date 12/06/2023
-- Based on: https://dba.stackexchange.com/a/216821 **

-- getting all of the listing details
SELECT `listing_id` AS `Listing ID`, `listing_name` AS `Listing Name`, Properties.property_name AS `Property Name`, 
`listing_date` AS `Listing Date`, FORMAT(`listing_price`, N'NO') AS `Listing Price`, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent`, 
CONCAT(Customers.customer_last_name,', ', Customers.customer_first_name) AS `Seller`, CASE WHEN `active_listing` = 1 THEN 'Yes' ELSE 'No' END AS `Active Listing?` 
FROM Listing_Details LEFT JOIN Properties ON Listing_Details.property_id = Properties.property_id 
LEFT JOIN Agents ON Listing_Details.selling_agent_id = Agents.agent_id LEFT JOIN Customers ON Listing_Details.selling_customer_id = Customers.customer_id 
ORDER BY `Listing ID` ASC;
    

-- add a new listing
INSERT INTO Listing_Details (listing_name, property_id, listing_date, listing_price, selling_agent_id, selling_customer_id, active_listing) 
VALUES (:listing_nameInput, :property_name_from_dropdown_Input, :listing_dateInput, :listing_priceInput,
 :selling_agent_id_from_dropdown_Input, :selling_customer_id_from_dropdown_Input, :active_listing_from_dropdown_Input)


-- --------------------------------------------------------------------------------

-- Property Transactions Entity



-- ** Citation for the following SELECT GROUP_CONCAT, Date 11/01/2023
-- Based on: https://www.w3schools.blog/concatenate-multiple-rows-into-one-field-mysql **

-- getting all of the property transactions entries in combination with intersection table
SELECT Property_Transactions.transaction_id AS `Transaction ID`, Property_Transactions.transaction_date AS `Transaction Date`, 
FORMAT(Property_Transactions.contract_price, N'NO') AS `Contract Price`, Listing_Details.listing_name AS `Listing Name`, 
GROUP_CONCAT(' ', Agents.agent_first_name, ' ', Agents.agent_last_name ) AS `Agents` FROM Property_Transactions 
LEFT JOIN Property_Transactions_has_Agents ON Property_Transactions.transaction_id = Property_Transactions_has_Agents.transaction_id 
JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id LEFT JOIN Agents ON Property_Transactions_has_Agents.agent_id = Agents.agent_id 
GROUP BY `Listing Name` ORDER BY Property_Transactions.transaction_id;
       


-- add a new Property Transaction
INSERT INTO Property_Transactions (transaction_date, contract_price, listing_id) 
VALUES (:transaction_dateInput, :contract_priceInput, :listing_id_from_dropdown_Input)


-- --------------------------------------------------------------------------------

-- Property Transactions-Agents Intersection Table

-- getting all of the intersection table entries
SELECT `intersection_id` AS `Intersection ID`, Listing_Details.listing_name AS `Listing Name`, 
CASE WHEN Agents.agent_id is NULL THEN 'Null' ELSE CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) END AS `Agent`
FROM (((Property_Transactions_has_Agents INNER JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id) 
INNER JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id) LEFT JOIN Agents ON Property_Transactions_has_Agents.agent_id = Agents.agent_id) 
ORDER BY `Listing Name` ASC;
   

-- add a new Property Transaction and Agents relationship
INSERT INTO Property_Transactions_has_Agents (transaction_id, agent_id) 
VALUES (:transaction_id_from_dropdown_Input, :agent_id_from_dropdown_Input)


-- --------------------------------------------------------------------------------

-- SELECT with a dynamically populated list of properites

-- get all of the Property Names to populate the Property Name dropdown
SELECT Properties.property_id AS property_id, Properties.property_name AS `Property Name` FROM Properties;
    
-- get all of the Agent Names to populate the Agent Name dropdown
SELECT Agents.agent_id AS agent_id, CONCAT(Agents.agent_last_name,', ', Agents.agent_first_name) AS `Agent Name`FROM Agents;
    
-- get all of the Customer Names to populate the Customer Name dropdown
SELECT Customers.customer_id AS customer_id, CONCAT(Customers.customer_last_name,', ', Customers.customer_first_name) AS `Customer Name` FROM Customers

-- get all of the Listing Names that are in Transactions table to populate the add Intersection Table's Listing Name dropdown
SELECT DISTINCT Property_Transactions.transaction_id AS `Transaction ID`, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Property_Transactions_has_Agents RIGHT JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id;  

-- get all of the Listing Names that are NOT in Transactions table to populate the add Transaction's Listing Name dropdown
SELECT Property_Transactions.transaction_id, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Listing_Details LEFT JOIN Property_Transactions ON Property_Transactions.listing_id = Listing_Details.listing_id AND Listing_Details.listing_id WHERE Property_Transactions.transaction_id IS NULL;

-- get Listing Names that have transaction IDs to populate the Listings Names dropdown 
SELECT DISTINCT Property_Transactions.transaction_id AS `Transaction ID`, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Property_Transactions_has_Agents 
JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id 
RIGHT JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id;

-- get all of the Listing Names to populate the Intersection's Lisitng Names dropdown
SELECT DISTINCT Property_Transactions.transaction_id AS `Transaction ID`, Listing_Details.listing_id AS `listing_id`, Listing_Details.listing_name AS `Listing Name` FROM Property_Transactions_has_Agents 
RIGHT JOIN Property_Transactions ON Property_Transactions_has_Agents.transaction_id = Property_Transactions.transaction_id 
JOIN Listing_Details ON Property_Transactions.listing_id = Listing_Details.listing_id;

-- --------------------------------------------------------------------------------

