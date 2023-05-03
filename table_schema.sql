CREATE TABLE card_holder (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE credit_card (
    card VARCHAR(20) PRIMARY KEY,
    cardholder_id INTEGER NOT NULL REFERENCES card_holder(id)
);

CREATE TABLE merchant_category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE merchant (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    id_merchant_category INTEGER NOT NULL REFERENCES merchant_category(id)
);

CREATE TABLE transaction (
    id INTEGER PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    card VARCHAR(20) NOT NULL REFERENCES credit_card(card),
    id_merchant INTEGER NOT NULL REFERENCES merchant(id)
);


