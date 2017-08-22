# ArchivesSpace Public (finding aids)

A Ruby on Rails application for presenting archival finding aids that uses data imported from ArchivesSpace. Used for [NCSU Libraries Special Collections Research Center Collection Guides](http://www.lib.ncsu.edu/findingaids/). Search across finding aids is provided via Apache Solr.

## Requirements

* Ruby 4.1 or higher
* Apache Solr 4 or higher
* Cron (for scheduled updates of data from ArchivesSpace)

## Configuration

Configuration files containing sensitive information are required but not included in this repository for security. These files need to be created manually.

### config/database.yml

Provide your database configuration options. You can use database_example.yml as a template. For more information see http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database

### config/application.yml
Provide information needed to connect to the Solr index and to ArchivesSpace. You can use application_example.yml as a template.

Configuration options include:
* `solr_host`: Your Solr host (e.g. 'solr.myinstitution.org', without the 'http://' protocol segment included)
* `solr_port`: The port number on which your Solr instance is running (required)
* `solr_core_path`: If you are running a multi-core instance of Solr, provide the path to your core (with leading and trailing slashes - e.g. '/solr/aspace_public/')
* `archivesspace_host`: The hostname for your ArchivesSpace instance, used for communication between DAEV and ArchivesSpace (localhost if running on the same server as the application)
* `archivesspace_url_host`: The hostname for your ArchivesSpace instance (e.g. 'archivesspace.myinstitution.org', without the 'http://' protocol segment included), used for generating links to the records in the ArchivesSpace front end
* `archivesspace_port`: Your ArchivesSpace backend port (8089 by default)
* `archivesspace_frontend_port`: Your ArchivesSpace frontend port (8080 by default)
* `archivesspace_solr_port`: Your ArchivesSpace Solr port (8090 by default)
* `archivesspace_solr_path`: path the the Solr core used by ArchivesSpace (by default this is '/collection1/')
* `archivesspace_username`: Username for an ArchivesSpace admin user
* `archivesspace_password`: Password associated with archivesspace\_username
* `archivesspace_https`: Set to true to force communication with ArchivesSpace over HTTPS

### config/secrets.yml
`secret_key_base` values for each environment. See http://guides.rubyonrails.org/4_1_release_notes.html#config-secrets-yml

## Functionality highlights

### Import from ArchivesSpace

The application stores in its database data retrieved from the ArchivesSpace API, providing a level of performance much higher than would be possible if API calls were made in real-time.

The `Resource`, `ArchivalObject`, `DigitalObject` and `Subject` models correspond to the classes with the same names in ArchivesSpace and retain the IDs assigned in ArchivesSpace. The `Agent` model aggregates records of the `AgentPerson`, `AgentCorporateEntity` and `AgentFamily` classes in ArchivesSpace (the `AgentSoftware` class is not currently used); the `agent_type` attribute is used to indicate the source class, and new IDs are assigned on import. For individual records of each of these classes, the data returned from the ArchivesSpace API is stored in the database (as JSON, in a MySQL LONGTEXT field) as `api_response`.

The `Resource` and `ArchivalObject` models store a second JSON object (`unit_data`) that includes the API response data, combined with data from associated `Agent`, `Subject` and `DigitalObject` records. Where applicable, dates and are parsed into a form suitable for presentation, and note contents are converted to HTML. The `update_unit_data` method in `app/models/concerns/api_response_data.rb` is responsible for processing the API response. This object is retrievable as a Ruby hash via the `parse_unit_data` instance method.

The `AspaceImport` model is responsible for pulling data from ArchivesSpace into the application database.


### Search and indexing

The Solr index includes both `Resource` (collection) records and `ArchivalObject` (component) records. The Solr doc for both classes are generated via the `solr_doc` method in `app/models/concerns/solr_doc.rb`.

The search results use Solr's [Result Grouping](https://cwiki.apache.org/confluence/display/solr/Result+Grouping) feature to aggregate component-level results with their parent collection in order to provide appropriate context.

The application uses the [RSolr](https://github.com/rsolr/rsolr) Ruby client for Apache Solr for all interactions with the Solr index. Solr configuration files are available in this repository for both Solr 4 (in `solr_4_conf`) and 5 (in `solr_conf`).

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
