# Web Server

## Overview

You’ll create a small server that lets you, create, list, show, update and delete quotes.

* POST   /quotes     Inserts a new quote into the DB.
* GET    /quotes     Returns all quotes.
* GET    /quotes/:id Returns one quote by ID.
* PATCH  /quotes/:id Updates an existing quote.
* DELETE /quotes/:id Deletes the quote by ID.

Each "quote" will have an ID, a title, and content.

## Testing

Run the spec suite with the environment variable DOMAIN set to the local uri of your app.

For example if the app currently runs on http://localhost:3000, run the acceptance test with:

    DOMAIN="http://localhost:3000" ruby acceptance_test.rb
