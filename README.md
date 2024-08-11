# ATask international assessment

create task for simple internal wallet transactional system (API)

## Tools
Tool | Description
--- | ---
**[Rails 7.0.4.3](http://api.rubyonrails.org/)** | Ruby on Rails API
**[Ruby 3.2.1](https://ruby-doc.org/core-2.4.1/)** | Ruby
**[Rspec](https://github.com/rspec/rspec-rails)** | Testing tool
**[PostgreSQL](https://www.postgresql.org/)** | Database

### Installation

How to [Install Rails](http://installrails.com/)

```sh
$ git clone git@github.com:tmluthfiana/internal-wallet.git
$ cd internal-wallet
$ bundle install
$ rake db:create && rake db:migrate
```

### Run Unit Testing

```sh
$ rspec spec/
```

### Features

A user can:
  - deposit to their wallet
  - withdraw from their wallet
  - transfer to another entities (User or Team)
  - get list all stocks
  - get stock from one indicies