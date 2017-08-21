# Positiv Flo Rails API

This is the API that connects to the iOS Trainer app.

## Getting started

### Setup

Run these commands to get started:

```
$ rake db:migrate
$ rake db:seed
```

**NOTE:** You have to run `rake db:seed` for the API to work. Running seed will generate the Bearer token which is used to authenticate any API actions.

There seems to be an issue with the migrations. They don't seem to be implementing a `postcode` field for `gym_locations`. I've had to run these commands when the seed fails.

```
$ rake db:migrate
$ rake db:seed
# Error because postcode cannot be found.
$ rake db:schema:load  # **ATTENTION** THIS WILL DROP THE DATA IN THE DB.
$ rake db:seed
```

You can start the rails server and its processes via foreman:

```
$ foreman start
```

Then navigate to `http://localhost:3000/documentation` to access the docs.

If you don't want to start the worker process you can just run:

```
$ rails server
```

## Sites to visit

### [Documentation](http://localhost:3000/documentation)

This is where all the documentation for the API is found. Inside the documentation you can find your bearer key. You will need this key to authenticate any API requests.

The login details to get past the http basic auth can be found at:

`app/controllers/documentation_controller.rb`

### [Admin Interface](http://localhost:3000/admin)

The admin interface is where you can view all the data that is captured by the Trainer app.

An Admin user is created when you first seed the database. See `seeds.rb` for an example of how an admin user is created.

## Semantic Versioning

This project adheres to [semver](http://semver.org/)

## Contributing

The `staging` branch is also the development branch. The most recent changes will be found in this branch. Any further changes will be pushed here.
