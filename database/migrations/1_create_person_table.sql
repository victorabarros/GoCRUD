CREATE TABLE IF NOT EXISTS persons (
    id            SERIAL     PRIMARY KEY,
    first_name    CHAR(4)    NOT NULL,
    created_at    TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
