-- Create the voting table
CREATE TABLE voting (
    id SERIAL PRIMARY KEY,
    vote VARCHAR(50) NOT NULL,
    voter_id VARCHAR(50) NOT NULL
);
