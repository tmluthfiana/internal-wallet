# Internal Wallet API

## Description

This is a simple internal wallet transactional system API built with Ruby on Rails. It allows users to manage their wallet balances through various operations, including deposits, withdrawals, and transfers. Additionally, it provides endpoints to interact with stock information.

## Installation

1. **Clone the repository:**

   ```sh
   $ git clone git@github.com:tmluthfiana/internal-wallet.git
   ```

2. **Navigate to the project directory:**

   ```sh
   $ cd internal-wallet
   ```

3. **Install dependencies:**

   ```sh
   $ bundle install
   ```

4. **Set up the database:**

   ```sh
   $ rake db:create
   $ rake db:migrate
   ```

## Running Unit Tests

To run the unit tests for this API, use RSpec:

```sh
$ rspec spec/
```

## Features

Users can perform the following actions:

- **Deposit:** Add funds to their wallet.
- **Withdraw:** Remove funds from their wallet.
- **Transfer:** Send funds to another user or team.
- **List All Stocks:** Retrieve a list of all available stocks.
- **Get Stock Price:** Retrieve the price of a specific stock.

## Routes

### Authentication

- **Sign In:**

  `POST /api/v1/auth/sign_in`

  Authenticates a user and returns access and refresh tokens.

- **Refresh Token:**

  `GET /api/v1/auth/refresh_token`

  Refreshes the access token using the provided refresh token.

### Transactions

- **Deposit:**

  `POST /api/v1/transactions/deposit`

  Deposits funds into the wallet.

- **Withdraw:**

  `POST /api/v1/transactions/withdraw`

  Withdraws funds from the wallet.

- **Transfer:**

  `POST /api/v1/transactions/transfer`

  Transfers funds to another user or team.

### Stocks

- **Get All Stock Prices:**

  `GET /api/v1/stocks/price_all`

  Retrieves the prices for all stocks.

- **Get Stock Price by Index:**

  `GET /api/v1/stocks/price`

  Retrieves the price of a specific stock based on its index.

## Tools

- **[Rails 7.0.4.3](http://api.rubyonrails.org/)**: Ruby on Rails API framework.
- **[Ruby 3.2.1](https://ruby-doc.org/core-2.4.1/)**: Ruby programming language.
- **[RSpec](https://github.com/rspec/rspec-rails)**: Testing framework.
- **[PostgreSQL](https://www.postgresql.org/)**: Database system.
