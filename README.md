# Collection guides

A Ruby on Rails application for presenting archival finding aids that uses data
imported from ArchivesSpace. Used for NC State University Libraries Special Collections Research Center Collection Guides](http://www.lib.ncsu.edu/findingaids/). Search across finding aids is
provided via Apache Solr.

## Requirements

* Ruby 2.7.2 or higher
* Apache Solr 7 or higher
* Cron (for scheduled updates of data from ArchivesSpace)



## Docker instructions

You need Docker installed. Also, make sure you have access to the mysqldump tool (brew install mysql-client on Mac, sudo apt install mariadb-client on Ubuntu).

    git clone git@github.ncsu.edu:ncsu-libraries/collection_guides.git
    cd collection_guides
    ./setup.sh
    docker-compose up

Depending on what you need to do you will need certain environmental variables to get things up and running, particularly in your external_services.yml and application.yml files. 

To get a shell in the wonda container (you can do this for any of the containers by replacing "wonda" with that container's name from docker-compose.yml):

    docker-compose exec collection_guides bash

Each time you build the wonda container you have to populate the index inside the container. 

    rails search_index:full

Start the Rails server when inside the container, and Wonda will be available at http://localhost:3000. 

    bundle exec rails s -b 0.0.0.0

To run specs from inside the container:

    RAILS_ENV=test rspec



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


## Installation/Configuration

See [INSTALLATION.md](./INSTALLATION.md).


## Author

Trevor Thornton


## License

See MIT-LICENSE
