# Installation and configuration

To begin:

1. Clone or download/unzip this repo
2. `cd` into the local collection_guides directory (the one you just cloned)

## Select and configure database

### To use SQLite (for development only)
Locate the file `config/database_example_sqlite.yml` and save a copy as
`config/database.yml`.

### To use MySQL

> NOTE: Using MySQL requires other MySQL components to already be available on your system.

1. Locate the file `config/database_example_mysql.yml` and save a copy as
`config/database.yml`. Update the information in this file as needed.
For more information see
http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database

2. In `Gemfile`, uncomment this line before proceeding:

   `# gem 'mysql2'`

## Basic setup

1. Run `bundle install` to install gems (requires Bundler - `gem install bundler`)
2. Run `bundle exec rake collection_guides:generate_secrets` to generate the
Rails secret\_key_base.

## Set up database

Run this to create the database:

`rake db:setup`

## Create Solr core

To use search features, a Solr core must be available. The `solr_conf` directory
contains Solr configuration files.



## Configuration

Configuration files containing sensitive information are required but not
included in this repository for security. These files need to be created manually.

### config/application.yml

Provide information needed to connect to the Solr index and to ArchivesSpace.
You can use `application_example.yml` as a template.

Configuration options (all required unless specified) include:
* `solr_host`: Your Solr host (e.g. 'solr.myinstitution.org', without the
'http://' protocol segment included)
* `solr_port`: The port number on which your Solr instance is running (required)
* `solr_core_path`: If you are running a multi-core instance of Solr,
provide the path to your core (with leading and trailing slashes - e.g. '/solr/aspace_public/')
* `archivesspace_host`: The hostname for your ArchivesSpace instance, used for communication between DAEV and ArchivesSpace (localhost if running on the same server as the application)
* `archivesspace_url_host`: The hostname for your ArchivesSpace instance (e.g. 'archivesspace.myinstitution.org', without the 'http://' protocol segment included), used for generating links to the records in the ArchivesSpace front end
* `archivesspace_port`: Your ArchivesSpace backend port (ArchivesSpace default is **8089**)
* `archivesspace_frontend_port`: Your ArchivesSpace frontend port (ArchivesSpace default is **8080**)
* `archivesspace_solr_port`: Your ArchivesSpace Solr port (ArchivesSpace default is **8090**)
* `archivesspace_solr_path`: path the the Solr core used by ArchivesSpace (ArchivesSpace default is **'/collection1/'**)
* `archivesspace_username`: Username for an ArchivesSpace admin user
* `archivesspace_password`: Password associated with *archivesspace\_username*
* `archivesspace_https`: Set to true to force communication with ArchivesSpace over HTTPS (OPTIONAL - defaults to false)


## Initial data import

Once the configuration files have been added and the Solr index is in place, data can be imported from ArchivesSpace via a single rake task:
`rake aspace_import:full`

This task will first import all repositories in your ArchivesSpace instance, then import each resource in each repository, along with all descendant archival\_object and digital\_object records, and subject and agent records associated with any of these. THIS PROCESS CAN TAKE A VERY LONG TIME, DEPENDING ON THE SIZE OF YOUR ARCHIVESSPACE DATABASE.

NOTES:

1. The application will only import published records, and resources must have a finding aid status of "complete". These conditions are not currently configurable.
2. There is currently nothing in the user interface to differentiate between repositories. In fact, beyond storing basic information about the repositories and their associations to `Resource` records, the application currently does not take repositories into consideration in any way.
