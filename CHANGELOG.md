# master

# Version 0.5.2

## Changes

  * `Chewy.massacre` aliased to `Chewy.delete_all` method deletes all the indexes with current prefix

## Incompatible changes:

  * `Chewy::Type::Base` removed in favour of using `Chewy::Type` as a base class for all types

## Bugfixes:

  * Advanced type classes resolving (@inbeom)

  * `import` ignores nil

# Version 0.5.1

## Changes:

  * `chewy.yml` Rails generator (@jirikolarik)

  * Parent-child mappings feature support (@inbeom)

  * `Chewy::Index.total_count` and `Chewy::Type::Base.total_count`

  * `Chewy::Type::Base.reset` method. Deletes all the type documents and performs import (@jondavidford)

  * Added `Chewy::Query#delete_all` scope method using delete by query ES feature (@jondavidford)

  * Rspec 3 `update_index` matcher support (@jimmybaker)

  * Implemented function scoring (@averell23)

## Bugfixes:

  * Indexed eager-loading fix (@leemhenson)

  * Field type deriving nested type support fix (@rschellhorn)

# Version 0.5.0

## Incompatible changes:

  * 404 exception (IndexMissingException) while query is swallowed and treated like an empty result set.

  * `load` and `preload` for queries became lazy. Might be partially incompatible.

  * Changed mapping behavior: multi-fields are defined in conformity with ElasticSearch documentation (http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/_multi_fields.html#_multi_fields)

## Changes:

  * `suggest` query options support (@rschellhorn).

  * Added hash data support. How it is possible to pass hashes to import.

  * `rake chewy:reset` and `rake chewy:update` paramless acts as `rake chewy:reset:all` and `rake chewy:update:all` respectively

  * Added `delete_from_index?` API method for custom deleted objects marking.

  * Added `post_filter` API, working the same way as filters.

  * Added chainable `strategy` query method.

  * Aliasing is performed in index create request for ElasticSearch >= 1.1.

  * `preload` scope method loads ORM/ODM objects in background.

  * `load` method `:only` and `:except` options to specify load types.

  * `highlight` and `rescore` query options support.

  * config/chewy.yml ERB support.

## Bugfixes:

  * Fixed `missing` and `exists` filters DSL constructors.

  * Reworked index data composing.

  * Support for Kaminari new PaginatableArray behavior (@leemhenson)

  * Correct waiting for status. After index creation, bulk import, and deletion.

  * Fix #23 "wrong constant name" with namespace models

# Version 0.4.0

  * Changed `update_index` matcher behavior. Now it compare array attributes position-independantly.

  * Search aggregations API support (@arion).

  * Chewy::Query#facets called without params performs the request and returns facets.

  * Added `Type.template` dsl method for root objects dynamic templates definition. See [mapping.rb](lib/chewy/type/mapping.rb) for more details.

  * ActiveRecord adapter custom `primary_key` support (@matthee).

  * Urgent update now clears association cache in ActiveRecord to ensure latest changes are imported.

  * `import` now creates index before performing.

  * `Chewy.configuration[:wait_for_status]` option. Can be set to `red`, `yellow` or `green`. If set - chewy will wait for cluster status before creating, deleting index and import. Useful for specs.

# Version 0.3.0

  * Added `Chewy.configuration[:index]` config to setup common indexes options.

  * `Chewy.client_options` replaced with `Chewy.configuration`

  * Using source filtering instead of fields filter (http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-request-source-filtering.html).

# Version 0.2.3

  * `.import!` indexes method, raises import errors.

  * `.import!` types method, raises import errors. Useful for specs.

# Version 0.2.2

  * Support for `none` scope (@undr).

  * Auto-resolved analyzers and analyzers repository (@webgago):

    ```ruby
      # Setting up analyzers repository:
      Chewy.analyzer :title_analyzer, type: 'custom', filter: %w(lowercase icu_folding title_nysiis)
      Chewy.filter :title_nysiis, type: 'phonetic', encoder: 'nysiis', replace: false

      # Using analyzers from repository in index classes
      class ProductsIndex < Chewy::Index
        settings analysis: {analyzer: ['title_analyzer', {one_more_analyzer: {type: 'custom', tokenizer: 'lowercase'}}]}
      end
    ```

    `title_analyzer` here will be automatically resolved and passed to index mapping

# Version 0.2.0

  * Reworked import error handling. Now all the import errors from ElasticSearch are handled properly, also import method returns true of false depending on the import process success.

  * `Chewy::Index.import` now takes types hash as argument within options hash:

    `PlacesIndex.import city: City.enabled, country: Country.enabled, refresh: false`

  * Old indexes cleanup after reset.

  * Added index prefixes.

  * `define_type` now takes options for adapter.

  * `chewy:reset` and `chewy:reset:all` rake tasks are now trying to reset index with zero downtime if it is possible.

  * Added `chewy:update:all` rake task.

  * Methods `.create`, `.create!`, `.delete`, `.delete`, `reset!` are now supports index name suffix passing as the first argument. See [actions.rb](lib/chewy/index/actions.rb) for more details.

  * Method `reset` renamed to `reset!`.

  * Added common loading scope for AR adapter. Also removed scope proc argument, now it executes just in main load scope context.

    `CitiesIndex.all.load(scope: {city: City.include(:country)})`
    `CitiesIndex.all.load(scope: {city: -> { include(:country) }})`
    `CitiesIndex.all.load(scope: ->{ include(:country) })`

# Version 0.1.0

  * Added filters simplified DSL. See [filters.rb](lib/chewy/query/filters.rb) for more details.

  * Queries and filters join system reworked. See [query.rb](lib/chewy/query.rb) for more details.

  * Added query `merge` method

  * `update_index` matcher now wraps expected block in `Chewy.atomic` by default.
    This behaviour can be prevented with `atomic: false` option passing

    ```ruby
      expect { user.save! }.to update_index('users#user', atomic: false)
    ```

  * Renamed `Chewy.observing_enabled` to `Chewy.urgent_update` with `false` as default

  * `update_elasticsearch` renamed to `update_index`, added `update_index`
    `:urgent` option

  * Added import ActiveSupport::Notifications instrumentation
    `ActiveSupport::Notifications.subscribe('import_objects.chewy') { |*args| }`

  * Added `types!` and `only!` query chain methods, which purges previously
    chained types and fields

  * `types` chain method now uses types filter

  * Added `types` query chain method

  * Changed types access API:

    ```ruby
      UsersIndex::User # => UsersIndex::User
      UsersIndex::types_hash['user'] # => UsersIndex::User
      UsersIndex.user # => UsersIndex::User
      UsersIndex.types # => [UsersIndex::User]
      UsersIndex.type_names # => ['user']
    ```

  * `update_elasticsearch` method name as the second argument

    ```ruby
      update_elasticsearch('users#user', :self)
      update_elasticsearch('users#user', :users)
    ```

  * Changed index handle methods, removed `index_` prefix. I.e. was
    `UsersIndex.index_create`, became `UsersIndex.create`

  * Ability to pass value proc for source object context if arity == 0
    `field :full_name, value: ->{ first_name + last_name }` instead of
    `field :full_name, value: ->(u){ u.first_name + u.last_name }`

  * Added `.only` chain to `update_index` matcher

  * Added ability to pass ActiveRecord::Relation as a scope for load
    `CitiesIndex.all.load(scope: {city: City.include(:country)})`

  * Added method `all` to index for query DSL consistency

  * Implemented isolated adapters to simplify adding new ORMs

  * Query DLS chainable methods delegated to index class
    (no longer need to call MyIndex.search.query, just MyIndex.query)

# Version 0.0.1

  * Query dsl

  * Basic index hadling

  * Initial version
