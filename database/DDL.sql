-- CS 340 - Introduction to Databases
-- Group 8 - Zedfin
-- Project Step 2

-- Team Members: Corie Gulik & Nancy Yang

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

-- --------------------------------------------------------------------------------

-- Creating the basic table structures

DROP TABLE IF EXISTS `Agents`;
CREATE TABLE `Agents` (
  `agent_id` int(11) NOT NULL UNIQUE AUTO_INCREMENT,
  `agent_first_name` varchar(145) NOT NULL,
  `agent_last_name` varchar(145) NOT NULL,
  `agent_phone` bigint(11) NOT NULL,
  `agent_email` varchar(145) NOT NULL,
  PRIMARY KEY (`agent_id`)
);

DROP TABLE IF EXISTS `Customers`;
CREATE TABLE `Customers` (
  `customer_id` int(11) NOT NULL UNIQUE AUTO_INCREMENT,
  `customer_first_name` varchar(145) NOT NULL,
  `customer_last_name` varchar(145) NOT NULL,
  `customer_phone` bigint(11) DEFAULT NULL,
  `customer_email` varchar(145) NOT NULL,
  `buying_property` tinyint(1) DEFAULT NULL,
  `buying_budget` bigint(11) DEFAULT NULL,
  `buying_agent` int(11) DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  CONSTRAINT FOREIGN KEY (buying_agent) REFERENCES Agents(agent_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS `Properties`;
CREATE TABLE `Properties` (
  `property_id` int(11) NOT NULL UNIQUE AUTO_INCREMENT,
  `property_name` varchar(145) NOT NULL UNIQUE,
  `no_of_rooms` int(11) NOT NULL,
  `no_of_bathrooms` int(11) NOT NULL,
  `sq_footage` bigint(11) NOT NULL,
  `garage` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`property_id`)
);

DROP TABLE IF EXISTS `Listing_Details`;
CREATE TABLE `Listing_Details` (
  `listing_id` int(11) NOT NULL AUTO_INCREMENT,
  `listing_name` varchar(145) NOT NULL UNIQUE,
  `property_id` int(11) NOT NULL,
  `listing_date` date NOT NULL,
  `listing_price` bigint(11) NOT NULL,
  `selling_agent_id` int(11) DEFAULT NULL,
  `selling_customer_id` int(11) DEFAULT NULL,
  `active_listing` tinyint(4) NOT NULL,
  PRIMARY KEY (`listing_id`),
  CONSTRAINT FOREIGN KEY (property_id) REFERENCES Properties(property_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (selling_agent_id) REFERENCES Agents(agent_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT FOREIGN KEY (selling_customer_id) REFERENCES Customers(customer_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS `Property_Transactions`;
CREATE TABLE `Property_Transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_date` date NOT NULL,
  `contract_price` bigint(11) NOT NULL,
  `listing_id` int(11),
  PRIMARY KEY (`transaction_id`),
  CONSTRAINT FOREIGN KEY (listing_id) REFERENCES Listing_Details(listing_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- the intersection table
DROP TABLE IF EXISTS `Property_Transactions_has_Agents`;
CREATE TABLE `Property_Transactions_has_Agents` (
  `intersection_id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) NOT NULL,
  `agent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`intersection_id`),
  CONSTRAINT FOREIGN KEY (transaction_id) REFERENCES Property_Transactions(transaction_id)
	ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (agent_id) REFERENCES Agents(agent_id)
	ON UPDATE CASCADE ON DELETE SET NULL
);

-- --------------------------------------------------------------------------------

-- Adding sample data into the tables

INSERT INTO `Agents` (`agent_first_name`, `agent_last_name`, `agent_phone`, `agent_email`) VALUES
('Avery', 'Anderson', 2147485467, 'avery.anderson@zedfin.com'),
('Barney', 'Bird', 2147483647, 'barney.bird@zedfin.com'),
('Chris', 'Candy', 2147482132, 'chris.candy@zedfin.com'),
('Dan', 'Duncan', 2147489654, 'dan.duncan@zedfin.com'),
('Ethan', 'Esty', 2147486625, 'ethan.esty@zedfin.com');

INSERT INTO `Customers` (`customer_first_name`, `customer_last_name`, `customer_phone`, `customer_email`, `buying_property`, `buying_budget`, `buying_agent`) VALUES
('Molly', 'Mason', 2147487465, 'molly.mason@somemail.com', 1, 1000000, (SELECT agent_id FROM Agents WHERE agent_email = "barney.bird@zedfin.com")),
('Nelson', 'Nile', 2147483352, 'nelson.nile@somemail.com', 1, 1100000, (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com")),
('Orla', 'Olson', 2147483434, 'orla.olson@somemail.com', 0, NULL, NULL),
('Patricia', 'Parson', 2147482008, 'patricia.parson@somemail.com', 0, NULL, NULL),
('Quentin', 'Quail', 2147483699, 'quentin.quail@somemail.com', 1, 900000, (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com"));

INSERT INTO `Properties` (`property_name`, `no_of_rooms`, `no_of_bathrooms`, `sq_footage`, `garage`) VALUES
('567 Square St', 2, 3, 1500, 0),
('123 Circle Ave', 3, 1, 1600, 0),
('456 Triangle Pl', 4, 3, 2200, 1),
('789 Star St', 3, 2, 1550, 1),
('321 Line Dr', 2, 2, 1600, 1);

INSERT INTO `Listing_Details` (`listing_name`, `property_id`, `listing_date`, `listing_price`, `selling_agent_id`, `selling_customer_id`, `active_listing`) VALUES
('2022-123 Circle Ave',(SELECT property_id FROM Properties WHERE property_name = "123 Circle Ave"), '2022-08-01', 950000, (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com"), (SELECT customer_id FROM Customers WHERE customer_email = "nelson.nile@somemail.com"), 0),
('2019-567 Square St',(SELECT property_id FROM Properties WHERE property_name = "567 Square St"), '2019-05-01', 880000, (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com"), NULL, 0),
('2018-321 Line Dr',(SELECT property_id FROM Properties WHERE property_name = "321 Line Dr"), '2018-06-23', 950000, (SELECT agent_id FROM Agents WHERE agent_email = "chris.candy@zedfin.com"), NULL, 0),
('2021-456 Triangle Pl',(SELECT property_id FROM Properties WHERE property_name = "456 Triangle Pl"), '2021-02-13', 1150000, (SELECT agent_id FROM Agents WHERE agent_email = "barney.bird@zedfin.com"), (SELECT customer_id FROM Customers WHERE customer_email = "quentin.quail@somemail.com"), 0),
('2021-789 Star St', (SELECT property_id FROM Properties WHERE property_name = "789 Star St"), '2021-10-01', 1080000, (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com"), (SELECT customer_id FROM Customers WHERE customer_email = "molly.mason@somemail.com"), 0),
('2023-123 Circle Ave', (SELECT property_id FROM Properties WHERE property_name = "123 Circle Ave"), '2023-09-03', 950000, (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com"), (SELECT customer_id FROM Customers WHERE customer_email = "orla.olson@somemail.com"), 1),
('2023-789 Star St', (SELECT property_id FROM Properties WHERE property_name = "789 Star St"), '2023-08-06', 1050000, (SELECT agent_id FROM Agents WHERE agent_email = "dan.duncan@zedfin.com"), (SELECT customer_id FROM Customers WHERE customer_email = "patricia.parson@somemail.com"), 1);

INSERT INTO `Property_Transactions` (`transaction_date`, `contract_price`, `listing_id`) VALUES
('2018-08-07', 949000, (SELECT listing_id FROM Listing_Details WHERE listing_name = "2018-321 Line Dr")),
('2021-03-15', 1175000, (SELECT listing_id FROM Listing_Details WHERE listing_name = "2021-456 Triangle Pl")),
('2019-06-30', 845000, (SELECT listing_id FROM Listing_Details WHERE listing_name = "2019-567 Square St")),
('2022-09-15', 980000, (SELECT listing_id FROM Listing_Details WHERE listing_name = "2022-123 Circle Ave")),
('2021-10-31', 1105000, (SELECT listing_id FROM Listing_Details WHERE listing_name = "2021-789 Star St"));

INSERT INTO `Property_Transactions_has_Agents` (`transaction_id`, `agent_id`) VALUES
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2018-321 Line Dr")), (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2021-456 Triangle Pl")), (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2019-567 Square St")), (SELECT agent_id FROM Agents WHERE agent_email = "chris.candy@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2022-123 Circle Ave")), (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2021-789 Star St")), (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2018-321 Line Dr")), (SELECT agent_id FROM Agents WHERE agent_email = "chris.candy@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2021-456 Triangle Pl")), (SELECT agent_id FROM Agents WHERE agent_email = "dan.duncan@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2019-567 Square St")), (SELECT agent_id FROM Agents WHERE agent_email = "ethan.esty@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2022-123 Circle Ave")), (SELECT agent_id FROM Agents WHERE agent_email = "avery.anderson@zedfin.com")),
((SELECT transaction_id FROM Property_Transactions WHERE listing_id = (SELECT listing_id FROM Listing_Details WHERE listing_name ="2021-789 Star St")), (SELECT agent_id FROM Agents WHERE agent_email = "dan.duncan@zedfin.com"));

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

