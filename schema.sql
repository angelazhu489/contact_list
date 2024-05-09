CREATE TABLE contacts (
	id serial PRIMARY KEY,
	first_name text NOT NULL,
	last_name text NOT NULL,
	phone_number text,
	email text,
	user_id int NOT NULL REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO contacts (first_name, last_name, phone_number, email, user_id) VALUES
 ('megan', 'choi', '1231231234', 'megchoi@gmail.com'),
 ('angela', 'zhu', '0987654321', 'angzhu@gmail.com');
