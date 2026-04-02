-- Create a simple but indexed schema for the assignment

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  monthly_income NUMERIC,
  credit_score INTEGER,
  employment_status TEXT,
  age INTEGER,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS loan_products (
  id SERIAL PRIMARY KEY,
  product_name TEXT,
  provider TEXT,
  interest_rate NUMERIC,
  min_monthly_income NUMERIC,
  min_credit_score INTEGER,
  max_credit_score INTEGER,
  eligibility_text TEXT,
  offer_url TEXT,
  fetched_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS matches (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  product_id INTEGER REFERENCES loan_products(id),
  score NUMERIC,
  matched_at TIMESTAMP DEFAULT now(),
  notified BOOLEAN DEFAULT FALSE
);

-- Indexes to speed up pre-filters
CREATE INDEX IF NOT EXISTS idx_users_income ON users(monthly_income);
CREATE INDEX IF NOT EXISTS idx_users_credit ON users(credit_score);
CREATE INDEX IF NOT EXISTS idx_loan_min_income ON loan_products(min_monthly_income);
CREATE INDEX IF NOT EXISTS idx_loan_min_credit ON loan_products(min_credit_score);
