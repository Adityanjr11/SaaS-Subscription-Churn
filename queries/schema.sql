CREATE DATABASE SAAS;
USE SAAS;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_date DATE,
    plan_type VARCHAR(20),
    acquisition_channel VARCHAR(20),
    country VARCHAR(20)
);

CREATE TABLE usage_metrics (
    user_id INT,
    avg_weekly_logins INT,
    feature_usage_score INT,
    support_tickets_last_30d INT,
    last_active_date DATE
);

CREATE TABLE subscription_status (
    user_id INT,
    monthly_price INT,
    discount_percent INT,
    churned INT,
    churn_date VARCHAR(20)
);





