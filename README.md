# Collection guides

A Ruby on Rails application for presenting archival finding aids that uses data
imported from ArchivesSpace. Used for NC State University Libraries Special Collections Research Center Collection Guides](http://www.lib.ncsu.edu/findingaids/). Search across finding aids is
provided via Apache Solr.

## Requirements

* Ruby 2.4.1 or higher
* Apache Solr 5 or 6
* Cron (for scheduled updates of data from ArchivesSpace)

## Installation

To begin:

1. Clone or download/unzip this repo
2. `cd` into the local collection_guides directory (the one you just cloned)

### Select and configure database

#### To use SQLite (for development only)
Locate the file `config/database_example_sqlite.yml` and save a copy as
`config/database.yml`.

#### To use MySQL

> NOTE: Using MySQL requires other MySQL components to already be available on your system.

1. Locate the file `config/database_example_mysql.yml` and save a copy as
`config/database.yml`. Update the information in this file as needed.
For more information see
http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database

2. In `Gemfile`, uncomment this line before proceeding:

   `# gem 'mysql2'`

### Basic setup

1. Run `bundle install` to install gems (requires Bundler - `gem install bundler`)
2. Run `bundle exec rake collection_guides:generate_secrets` to generate the
Rails secret\_key_base.

### Set up database

Run this to create the database:

`rake db:setup`

### Create Solr core

To use search features, a Solr core must be available. The `solr_conf` directory
contains Solr configuration files.
These have only beed tested on Solr versions 5 and 6 and may not work on Solr 7.

#### TODO:

* Solr 7 config
* expanded documentation

## Configuration

Configuration files containing sensitive information are required but not
included in this repository for security. These files need to be created manually.

### config/application.yml

Provide information needed to connect to the Solr index and to ArchivesSpace.
You can use `application_example.yml` as a template.

#### ArchivesSpace connection parameters

These facilitate communication with the ArchivesSpace API. Options are available to support a variety of
ArchivesSpace deployment scenarios.

* **archivesspace_host** (ex. *archivespace.yourhost.org*)<br>
The host name for the ArchivesSpace instance.
This option should be used for the 'default' ArchivesSpace deployment scenario,
with each component sharing a host but served on different ports.

* **archivesspace_backend_host** (ex. *api.archivespace.yourhost.org*)<br>
The hostname for the ArchivesSpace backend (API).
Use this option if the backend uses an unique host name. If present, this value
will override **archivesspace_host**

* **archivesspace_solr_host** (ex. *solr.archivespace.yourhost.org*)<br>
The hostname for the ArchivesSpace Solr instance.
Use this option if ArchivesSpace's Solr uses an unique host name. If present, this value
will override **archivesspace_host**

* **archivesspace_backend_port** (ex. *8089*)<br>
The port number used to connect to the ArchivesSpace backend. If your deployment
does not require a port number (e.g. for SSL) **do not include this option**.

* **archivesspace_solr_port** (ex. *8090*)<br>
The port number used to connect to the ArchivesSpace Solr instance. If your deployment
does not require a port number (e.g. for SSL) **do not include this option**.

* **archivesspace_username**: User name used to connect to ArchivesSpace.
User should have read access to all resources.

* **archivesspace_password**: Password associated with archivesspace_username

* **archivesspace_https**: To force connections via https, set this to '1',
otherwise leave it out.


#### Solr connection parameters

These are required to connect to your Solr index.

* **solr_host** (ex. *solr.yourhost.org*): The host name of your active Solr installation
* **solr_port** (ex. *8983*): The port on which your Solr instance is running
* **solr_core_name** (ex. *collection_guides*): The name of the Solr core used by Circa
* **solr_core_path** (ex. *'/solr/collection_guides'*): The path to the Solr core used by Circa
(relative to Solr root - include leading slash)


## Functionality highlights

### Import from ArchivesSpace

The application stores in its database data retrieved from the ArchivesSpace API, providing a level of performance much higher than would be possible if API calls were made in real-time.

The `Resource`, `ArchivalObject`, `DigitalObject` and `Subject` models correspond to the classes with the same names in ArchivesSpace and retain the IDs assigned in ArchivesSpace. The `Agent` model aggregates records of the `AgentPerson`, `AgentCorporateEntity` and `AgentFamily` classes in ArchivesSpace (the `AgentSoftware` class is not currently used); the `agent_type` attribute is used to indicate the source class, and new IDs are assigned on import. For individual records of each of these classes, the data returned from the ArchivesSpace API is stored in the database (as JSON, in a MySQL LONGTEXT field) as `api_response`.

The `Resource` and `ArchivalObject` models store a second JSON object (`unit_data`) that includes the API response data, combined with data from associated `Agent`, `Subject` and `DigitalObject` records. Where applicable, dates and are parsed into a form suitable for presentation, and note contents are converted to HTML. The `update_unit_data` method in `app/models/concerns/api_response_data.rb` is responsible for processing the API response. This object is retrievable as a Ruby hash via the `parse_unit_data` instance method.

The `AspaceImport` model is responsible for pulling data from ArchivesSpace into the application database.


### Search and indexing

The Solr index includes both `Resource` (collection) records and `ArchivalObject` (component) records. The Solr doc for both classes are generated via the `solr_doc` method in `app/models/concerns/solr_doc.rb`.

The search results use Solr's [Result Grouping](https://cwiki.apache.org/confluence/display/solr/Result+Grouping) feature to aggregate component-level results with their parent collection in order to provide appropriate context.

The application uses the [RSolr](https://github.com/rsolr/rsolr) Ruby client for Apache Solr for all interactions with the Solr index. Solr configuration files are available in this repository in `solr_conf`.

### Finding aid presentation

The finding aid display works differently depending on the size of the collection. For smaller collections (less than 1000 components), the entire 'contents' (container list) section loads upon request. For larger collections, the container list is first rendered as an HTML skeleton with no actual content. This structure is actually stored in a column in the resources table (`structure` - the value is generated on import from ArchivesSpace), so it it available without performing additional queries. Then the components load, starting at the top, in batches of 50 via AJAX requests - so the top loads first and the parts "below the fold" load after. This usually results in a seamless experience for the user.

## Initial data import

Once the configuration files have been added and the Solr index is in place, data can be imported from ArchivesSpace via a single rake task:
`rake aspace_import:full`

This task will first import all repositories in your ArchivesSpace instance, then import each resource in each repository, along with all descendant archival\_object and digital\_object records, and subject and agent records associated with any of these. THIS PROCESS CAN TAKE A VERY LONG TIME, DEPENDING ON THE SIZE OF YOUR ARCHIVESSPACE DATABASE.

NOTES:

1. The application will only import published records, and resources must have a finding aid status of "complete". These conditions are not currently configurable.
2. There is currently nothing in the user interface to differentiate between repositories. In fact, beyond storing basic information about the repositories and their associations to `Resource` records, the application currently does not take repositories into consideration in any way.

## Author

Trevor Thornton

## License

See MIT-LICENSE
