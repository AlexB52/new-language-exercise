# Web Server

## Overview

You’ll create a small server that lets you, create, list, show, update and delete quotes.

* POST   /quotes:     Inserts a new quote into the DB.
* GET    /quotes:     Returns all quotes.
* GET    /quotes/:id: Returns one quote by ID.
* PUT    /quotes/:id: Updates an existing quote.
* DELETE /quotes/:id: Deletes the quote by ID.

Each "quote" will have an ID, a title, and content.

## Testing

Run the spec suite with the environment variable of the local uri

LANL_WEB_SERVER_URI="http://localhost:3000" ruby web_server
