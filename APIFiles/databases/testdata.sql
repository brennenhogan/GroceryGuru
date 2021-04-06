INSERT INTO login (id, name, password, uuid)
VALUES
    (1, 'bhogan', 'p', 'breezynbezgcneoqqwdjafvqh'),
    (2, 'bsailer', 'p', 'brickfertyhnbvsdfgreqewed');

INSERT INTO list (list_id, name, old)
VALUES
    (1, 'Group Grocery', 0),
    (2, 'Personal Items', 0),
    (3, 'Cookout', 0),
    (4, 'Picnic', 0);

INSERT INTO store (store_id, store_name, list_id)
VALUES
    (1, 'Martins', 1),
    (2, 'Walmart', 1),
    (3, 'ALDI', 1),
    (4, 'Walmart', 2),
    (5, 'Walmart', 3),
    (6, 'Walmart', 4);

INSERT INTO list_ownership (uuid, list_id)
VALUES
    ('breezynbezgcneoqqwdjafvqh', 1),
    ('brickfertyhnbvsdfgreqewed', 1),
    ('brickfertyhnbvsdfgreqewed', 2),
    ('brickfertyhnbvsdfgreqewed', 3),
    ('brickfertyhnbvsdfgreqewed', 4);

INSERT INTO list_item (item_id, list_id, store_id, qty, description, purchased)
VALUES
    (1, 1, 1, 2, 'bananas', 0),
    (2, 1, 1, 1, 'apples', 0),
    (3, 1, 2, 6, 'pears', 0),
    (4, 1, 2, 4, 'cherries', 0),
    (5, 2, 4, 2, 'meat', 0),
    (6, 2, 4, 1, 'buns', 0),
    (7, 2, 4, 6, 'ketchup', 0),
    (8, 2, 4, 4, 'cheese', 0);

INSERT INTO recipe (recipe_id, name, uuid)
VALUES
    (1, 'Fruit salad', 'brickfertyhnbvsdfgreqewed'),
    (2, 'Cookout', 'brickfertyhnbvsdfgreqewed');

INSERT INTO recipe_item (item_id, recipe_id, store_id, qty, description)
VALUES
    (1,1,1,5,'bananas'),
    (2,1,1,5,'apples'),
    (3,1,2,5,'pears'),
    (4,1,2,5,'cherries'),
    (5,2,1,5,'meat');
