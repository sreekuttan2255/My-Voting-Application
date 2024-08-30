-- Create the voting table
CREATE TABLE voting (
    id SERIAL PRIMARY KEY,
    voter_id VARCHAR(100) NOT NULL,
    vote VARCHAR(100) NOT NULL
);
