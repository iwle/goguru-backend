DROP TABLE IF EXISTS Backingfunds CASCADE;
DROP TABLE IF EXISTS Comments CASCADE;
DROP TABLE IF EXISTS Creates CASCADE;
DROP TABLE IF EXISTS Feedbacks CASCADE;
DROP TABLE IF EXISTS Follows CASCADE;
DROP TABLE IF EXISTS Likes CASCADE;
DROP TABLE IF EXISTS Projects CASCADE;
DROP TABLE IF EXISTS Rewards CASCADE;
DROP TABLE IF EXISTS Searches CASCADE;
DROP TABLE IF EXISTS Searchhistory CASCADE;
DROP TABLE IF EXISTS Topupfunds CASCADE;
DROP TABLE IF EXISTS Transactions CASCADE;
DROP TABLE IF EXISTS Transactions_Transaction_Id_Sq CASCADE;
DROP TABLE IF EXISTS Transferfunds CASCADE;
DROP TABLE IF EXISTS Updates CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Wallets CASCADE;

CREATE TABLE Users (
	email varchar(255) NOT NULL PRIMARY KEY,
	full_name varchar(255) NOT NULL,
    phone_number varchar(255) NOT NULL UNIQUE,
    password_hash varchar(255) NOT NULL,
    user_created_timestamp timestamp NOT NULL,
    user_last_login_timestamp timestamp NOT NULL
);

CREATE TABLE Projects (
    project_name varchar(255) PRIMARY KEY,
    project_description text,
    project_deadline timestamp,
    project_category varchar(255),
    project_funding_goal integer ,
    project_current_funding integer DEFAULT 0,
    project_image_url varchar(255),
    email varchar(255) REFERENCES Users(email) ON DELETE CASCADE,
    project_created_timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_goal CHECK(project_funding_goal > 0)
);

CREATE TABLE Rewards (
    project_name varchar(255) REFERENCES Projects(project_name) ON UPDATE CASCADE ON DELETE CASCADE,
    reward_name varchar(255),
    reward_pledge_amount numeric(20,2) DEFAULT 0,
    reward_description text,
    reward_tier_id int,
    CONSTRAINT
      project_tier_constraint1
      UNIQUE(project_name, reward_name),
    CONSTRAINT
      project_tier_constraint2
      UNIQUE(project_name, reward_tier_id)
);

CREATE TABLE Follows (
    follower_id varchar(255) REFERENCES Users(email),
    following_id varchar(255) REFERENCES Users(email),
    CONSTRAINT follows_constraint PRIMARY KEY(follower_id, following_id)
);

CREATE TABLE Likes (
    email varchar(255) REFERENCES Users(email),
    project_name varchar(255) REFERENCES Projects(project_name),
    CONSTRAINT likes_constraint PRIMARY KEY(email, project_name)
);

CREATE TABLE Transactions (
    transaction_id serial PRIMARY KEY,
    amount numeric(20,2) NOT NULL,
    transaction_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE TopUpFunds (
    transaction_id integer REFERENCES Transactions(transaction_id) ON DELETE CASCADE,
    email varchar(255) REFERENCES Users(email)
);


CREATE TABLE TransferFunds (
    transaction_id integer REFERENCES Transactions(transaction_id) ON DELETE CASCADE,
    email_transferer varchar(255) REFERENCES Users(email),
    email_transfee varchar(255) REFERENCES Users(email)
);

CREATE TABLE BackingFunds(
    transaction_id integer REFERENCES Transactions(transaction_id) ON DELETE CASCADE,
    email varchar(255) REFERENCES Users(email),
    project_name varchar(255) REFERENCES Projects(project_name),
    reward_name varchar(255),
    FOREIGN KEY (project_name, reward_name) REFERENCES Rewards(project_name, reward_name),
    CONSTRAINT backingfunds_constrant UNIQUE(email, project_name, reward_name)
);


CREATE TABLE Creates (
    project_name varchar(255) REFERENCES Projects(project_name),
    email varchar(255) REFERENCES Users(email),
    create_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT creates_constraint PRIMARY KEY(email, project_name)
);

CREATE TABLE SearchHistory (
    search_timestamp timestamp,
    search_text varchar(255),
    email varchar(255) REFERENCES Users(email),
    PRIMARY KEY(email,search_timestamp)
);

CREATE TABLE Searches (
    email varchar(255) REFERENCES Users(email) ON DELETE CASCADE,
    search_timestamp timestamp,
    FOREIGN KEY (email,search_timestamp) REFERENCES SearchHistory(email,search_timestamp),
    CONSTRAINT
        unique_search
        UNIQUE (email,search_timestamp)
);

CREATE TABLE Wallets (
    email varchar(255) REFERENCES Users(email) ON DELETE CASCADE UNIQUE,
    amount numeric NOT NULL
);

CREATE TABLE Feedbacks (
    project_name varchar(255) REFERENCES Projects(project_name) ON DELETE CASCADE,
    feedback_text text,
    rating_number int,
    feedback_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ,
    email varchar(255) REFERENCES Users(email),

    CONSTRAINT
        feedback_not_null
        CHECK (feedback_text IS NOT NULL OR rating_number IS NOT NULL),
    CONSTRAINT
        unique_user_to_project1
        UNIQUE (email,project_name)
);

CREATE TABLE Comments (
    project_name varchar(255) REFERENCES Projects(project_name) ON DELETE CASCADE,
    comment_text text,
    comment_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email varchar(255) REFERENCES Users(email),

    CONSTRAINT
        comment_not_null
        CHECK (comment_text IS NOT NULL),

    CONSTRAINT
        unique_user_to_project_comment_date
        UNIQUE (email,project_name, comment_date)
);

CREATE TABLE Updates (
    project_name varchar(255) REFERENCES Projects(project_name) ON DELETE CASCADE,
    update_title text,
    update_description text,
    update_time timestamp,

    CONSTRAINT
      project_update_constraint1
      UNIQUE(update_time, project_name)
);
