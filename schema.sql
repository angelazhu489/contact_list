DROP TABLE contacts;

CREATE TABLE contacts (
	id serial PRIMARY KEY,
	first_name text NOT NULL,
	last_name text NOT NULL,
	phone_number text,
	email text
);

INSERT INTO contacts (first_name, last_name, phone_number, email) VALUES
 ('Megan', 'Choi', '1231231234', 'megchoi@gmail.com'),
 ('Angela', 'Zhu', '0987654321', 'angzhu@gmail.com'),
 ('Franny', 'Sun', '7878787878', 'fransun@gmail.com');
