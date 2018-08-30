# BrisaBoards Backend

This is the Ruby on Rails backend for http://BrisaBoards.com.

## Development

This repository contains the backend (API) for BrisaBoards. There is also a brisa-frontend repository
for the frontend. For now, the steps below will explain how to develop for both the frontend and
backend together.

### Requirements

The backend is written in Ruby on Rails 5, and Ruby version 2.5. The backend also requires PostgreSQL
version 9 or higher due to the use of array and jsonb columns.

### Setup Process

This process is a bit short. Hopefully it can be expanded later. If you have specific issues while
attempting to install and run Brisa, please file an issue. This process will be made easier!

1. Make sure postgresql is installed and running. Add a user and database for brisa.
2. Make sure your version of Ruby is supported by Rails 5. Using https://rvm.io to have a local
   version of Ruby of your choosing is the best way to do this.
3. gem install rails
4. Check out the brisa-backend repository.
5. Run bundle install to install dependencies.
6. Configure the config/database.yml file with your postgres config. Configure the master key
   and credentials. (TODO: Make this step way easier!)
7. Run rake db:migrate to create tables.
8 You can run ./add-admin-user.sh <email> (in Linux/OSX) to setup an admin user and pass.
9. Run rails server to start the development server.
10. If you have checked out the brisa-frontend code, a few lines of poi need to be patched to build
    to access the backend. poi --vars.BACKEND=http://localhost:3000/brisa build will
    build a dist directory that can be copied into brisa-backend/public, or you can run
    poi --vars.BACKEND=http://localhost:3000/brisa develop to run a local node server
    that will work with the backend.
