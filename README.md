# Roomies

Roomies is a web platform designed to match people who have a free room in a shared home with people looking for a place to live. Rather than treating shared housing as a pure transaction, Roomies facilitates the entire matching journey: browsing and searching listings, applying privately, scheduling visits, and finalizing roommate selections.

Project developed for the **Web Technologies**, Faculty of Engineering and Applied Sciences, **Universidad de los Andes**.

## Project Documentation
All the technical documents, models, and diagrams for this project are located in the docs/ folder. Click the links below to navigate through the requirements:

* [User Stories](docs/user-stories.md) - Contains the justifying user stories and acceptance criteria.
* [Domain Model](docs/domain-model.md)- Contains the ER diagram, database schema, and design decisions. [View the simplified diagram](docs/domain-model.png).
* [Decisions](docs/decisions.pdf) - Contains the modeling decisions, domain assumptions, entity definitions, lifecycle states, and constraints used in the Roomies relational domain model. 


## Structure

```text
.
├── docs/
│   ├── user_stories.md          # Complete user stories covering all platform roles
│   ├── domain_model.md          # DBML source with image, changes made since start
│   ├── domain_model.png         # Exported image of the relational database diagram
│   └── design_decisions.pdf     # Domain model design decisions
├── index.html                   # Main static landing page
├── style.css                    # Custom styles complementing Bootstrap 5
├── img/                         # Images of the project
└── README.md                    # Project overview
```

# Dependencies
* __Ruby:__ 3.3.8
* __Rails:__ 8.1.4
* __Node.js:__ 20.20.2
* __PostgresSQL:__ 18.6
* __Yarn:__ 1.22.22
* __PostgreSQL Role:__ A role matching your system's username with permissions to create databases

_Note: For a step-by-step guide to installing the dependencies [visit this link](https://brainy-barometer-470.notion.site/Install-Ruby-on-Rails-on-Windows-62a5e4ec60bb4697add5b3dd0fd56dac)_

## Setup instructions
Run the following commands in order to configure the project locally.

1. Clone the repository and navigate into the project directory:
```
git clone https://github.com/jpberrios1/webtech-project
cd webtech-project
```

2. Install required Ruby gems:
```
bundle install
```
3. Install the Node packages and dependencies required for frontend bundling:
```
yarn install
```

4. Build and populate the database
```
bin/rails db:drop db:create db:migrate db:seed
```
5. Build the CSS (Crucial to compile Boostrap for the first time)
```
yarn build:css
```
## Starting the Application
To run the application, you must use the development script. This ensures the local Sass compiler processes the custom Bootstrap stylesheets in real-time alongside the Rails server.

**NOTES**

* Do NOT use the standard `rails server` or `bin/rails s` commands, otherwise the page will load without styling
* The `database.yml` is configured to read the `POSTGRES_PASSWORD` environment variable. If your local PostgreSQL setup requires a password, please provide it when running the commands. For example:

```
POSTGRES_PASSWORD=your_password bin/rails db:setup
POSTGRES_PASSWORD=your_password bin/dev`
```

Start the application by running:
```
bin/dev
```
Once the processes boot up successfully, open your browser and visit `http://127.0.0.1:3000/` to see the website. 


## Authors

[Juan Pablo Berríos](https://github.com/jpberrios1)  
[Agustin Flores](https://github.com/AgustinFlores1)  
[Ana Cecilia Lobo](https://github.com/ana-cecilia-lobo-mila)  
