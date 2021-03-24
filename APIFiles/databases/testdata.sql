INSERT INTO login (id, name, password, uuid)
VALUES
    (1, 'brennen.hogan@gmail.com', 'password', 'breezynbezgcneoqqwdjafvqh'),
    (2, 'bsailer1@nd.edu', 'password', 'brickfertyhnbvsdfgreqewed');

INSERT INTO store (store_id, store_name)
VALUES
    (1, 'Martins'),
    (2, 'Walmart'),
    (3, 'ALDI');

INSERT INTO list_ownership (uuid, list_id)
VALUES
    ('breezynbezgcneoqqwdjafvqh', 1),
    ('brickfertyhnbvsdfgreqewed', 1),
    ('brickfertyhnbvsdfgreqewed', 2),
    ('brickfertyhnbvsdfgreqewed', 3),
    ('brickfertyhnbvsdfgreqewed', 4);

INSERT INTO list (list_id, name, old)
VALUES
    (1, 'Group Grocery', 0),
    (2, 'Personal Items', 0),
    (3, 'Cookout', 0),
    (4, 'Picnic', 0);

INSERT INTO list_item (item_id, list_id, store_id, qty, description, purchased)
VALUES
    (1, 1, 1, 2, 'bananas', 0),
    (2, 1, 1, 1, 'apples', 0),
    (3, 1, 2, 6, 'pears', 0),
    (4, 1, 2, 4, 'cherries', 0),
    (5, 2, 1, 2, 'meat', 0),
    (6, 2, 1, 1, 'buns', 0),
    (7, 2, 2, 6, 'ketchup', 0),
    (8, 2, 3, 4, 'cheese', 0);