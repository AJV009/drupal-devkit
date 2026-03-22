---
name: drupal-search-api
description: Manage Drupal Search API servers, indexes, fields, processors, and indexing operations. Use when creating search infrastructure, configuring search backends (Database, Solr, AI/vector search), adding fields or processors to indexes, or running indexing operations.
metadata:
  category: "drupal"
  drupal_version: "11.x"
  skill_version: "1.0.0"
  last_updated: "2026-03-21"
  source_module: "ai_agents_search_api"
  source_project: "https://www.drupal.org/project/ai_agents"
  requires: "search_api"
  tool_count: 13
---

# Drupal Search API

Manage search servers, indexes, fields, processors, and indexing operations for a Drupal site using the Search API module. This skill covers the full lifecycle of search configuration -- from enabling a backend and creating a server, through index and field setup, to processor tuning and indexing operations.

Converted from the `ai_agents_search_api` Drupal AI agent (part of the [AI Agents](https://www.drupal.org/project/ai_agents) project).

## When to Use

Trigger this skill when:
- User asks to "set up search" or "configure Search API"
- User wants to create or manage a search server or index
- User needs to add, remove, or list fields on a search index
- User asks about search processors (HTML filter, stemmer, tokenizer, etc.)
- User wants to run indexing, reindex, or check indexing status
- User mentions Solr, Elasticsearch, database search, or AI/vector search in Drupal
- User asks about faceted search, full-text search, or semantic search setup

## Key Concepts

- **Server**: A search backend connection (Database, Solr, Elasticsearch, AI Search). Each server can host multiple indexes.
- **Index**: A searchable collection of content. Each index belongs to one server and defines which content types to index, what fields to expose, and which processors to apply.
- **Datasource**: Defines what content an index tracks (e.g. `entity:node`, `entity:taxonomy_term`, `entity:user`). An index can have multiple datasources.
- **Fields**: Properties from content entities that are indexed and made searchable. Each field has a type (`string`, `text`, `integer`, `date`, `boolean`, `decimal`).
- **Processors**: Plugins that alter how content is indexed and searched (e.g. HTML stripping, tokenization, stemming, content access).
- **Tracker**: Tracks which items need indexing. The default tracker handles this automatically.

## Available Backends

| Backend ID | Name | Description |
|---|---|---|
| `search_api_db` | Database | Built-in backend using the site database. Good for small-to-medium sites. No extra infrastructure needed. |
| `search_api_solr` | Solr | Apache Solr backend for advanced full-text search. Requires a Solr server. |
| `search_api_ai_search_backend` | AI Search | Vector/semantic search backend from the AI module. Uses embeddings for RAG and semantic search capabilities. |

## Tool Inventory

The following 13 tools are available for search management:

| # | Tool ID | Label | Description |
|---|---------|-------|-------------|
| 1 | `list_servers` | List Search API Servers | Lists all servers with ID, name, backend, status, and availability. |
| 2 | `get_server` | Get Search API Server | Gets detailed info about a server including backend config, status, and connected indexes. |
| 3 | `create_server` | Create Search API Server | Creates a new server with a specified backend. For `search_api_db`, sensible defaults are applied automatically. |
| 4 | `delete_server` | Delete Search API Server | Deletes a server. The server cannot be deleted if it still has indexes attached -- remove or reassign indexes first. |
| 5 | `list_indexes` | List Search API Indexes | Lists all indexes with ID, name, server, status, datasources, field count, and tracker statistics. Optionally filter by server. |
| 6 | `get_index` | Get Search API Index | Gets comprehensive details about an index including fields, processors, datasources, tracker stats, and options. |
| 7 | `create_index` | Create Search Index | Creates a new index on a server with datasources. Configure bundles to restrict which content types are indexed. |
| 8 | `update_index` | Update Search Index | Updates settings on an existing index such as name, description, server, status, and options like `cron_limit` and `index_directly`. |
| 9 | `delete_index` | Delete Search Index | Deletes an index and all its indexed data. This action cannot be undone. |
| 10 | `manage_index_fields` | Manage Index Fields | Add, remove, or list available fields on an index. Supports actions: `add`, `remove`, `list_available`. |
| 11 | `manage_index_processors` | Manage Index Processors | Add, remove, or list processors on an index. Supports actions: `add`, `remove`, `list_available`, `list_enabled`. |
| 12 | `index_operations` | Index Operations | Perform indexing operations: `status`, `reindex` (mark all for re-indexing), `clear` (delete indexed data), or `index_now` (index a batch immediately). |
| 13 | `enable_search_backend` | Enable Search Backend | Enables a search backend module (`search_api_db`, `search_api_solr`, or `elasticsearch_search_api`). |

## Common Processors

| Processor ID | Purpose |
|---|---|
| `content_access` | Restricts search results based on user permissions (recommended for most indexes) |
| `html_filter` | Strips HTML tags from indexed content |
| `ignorecase` | Makes searches case-insensitive |
| `tokenizer` | Splits text into individual words for indexing |
| `stemmer` | Reduces words to their root form (running -> run) |
| `stopwords` | Removes common words (the, a, is, etc.) |
| `transliteration` | Converts special characters to ASCII equivalents |
| `rendered_item` | Indexes the rendered output of entities |
| `add_url` | Adds the entity URL to indexed data |
| `aggregated_field` | Creates virtual fields combining multiple source fields |
| `highlight` | Highlights search terms in results |

## Default Field Recommendations

For content indexes, these fields provide a solid starting point:

| Field | Type | Notes |
|---|---|---|
| `title` | text | Node title for full-text search (boost 5.0 recommended) |
| `body` | text | Body/content field for full-text search |
| `created` | date | Creation date for sorting and filtering |
| `changed` | date | Last modified date |
| `type` | string | Content type for filtering/faceting |
| `uid` | integer | Author for filtering |
| `status` | boolean | Published status |
| `sticky` | boolean | Sticky flag for boosting |

## Default Backend Configuration

For the **search_api_db** backend:
- `min_chars`: 1 (minimum word length to index)
- `matching`: partial (allows partial word matching)

## AI Search / Vector Search

The AI Search backend (`search_api_ai_search_backend`) from the `ai_search` module enables:
- Vector embeddings for semantic search
- RAG (Retrieval Augmented Generation) capabilities
- Similarity-based search instead of keyword matching
- Integration with AI providers for embedding generation

## Recommended Setup Workflow

Follow this order when building search infrastructure from scratch:

### Step 1: Enable a backend

Check available backends with `list_servers` or enable one with `enable_search_backend`. Start with `search_api_db` for simple setups that need no extra infrastructure.

### Step 2: Create a server

Create a server with the desired backend. For database backend, sensible defaults are applied if no backend config is provided.

### Step 3: Create an index

Create an index on that server, selecting datasources (e.g. `entity:node`). Optionally restrict to specific bundles (e.g. only `article` and `page` content types).

### Step 4: Add fields

Add fields to the index. Start with title, body, created date, content type, author, and status. Set appropriate types (text for full-text search, string for exact match/facets, date for date fields).

### Step 5: Add processors

Add processors for search quality. Common defaults: `content_access`, `html_filter`, `ignorecase`, `tokenizer`.

### Step 6: Run initial indexing

Use `index_operations` with the `index_now` operation to index a batch of items, or `reindex` to mark everything for indexing on the next cron run.

## Safety Warnings

- Deleting a server will disconnect all its indexes
- Clearing an index removes all indexed data (requires full re-indexing)
- Reindexing marks all items for re-indexing but does not delete existing data
- Adding/removing processors may require reindexing
- Large `index_now` operations may time out -- use reasonable batch sizes (50-100)
- Always check for connected indexes before deleting a server

## Example Workflows

### View current search configuration

```
"List all Search API servers"
"Show me all search indexes and their status"
"What fields are indexed on the content index?"
```

### Set up a basic database search

```
"Create a database search server"
"Create a content search index on the database server"
"Add the title, body, created, and type fields to the index"
"Enable the HTML filter, ignore case, and tokenizer processors"
"Index all items now"
```

### Set up a full-text article search

```
"Set up an index for articles and pages with title, body, and tags fields"
"Configure the stemmer processor for English language"
"Enable content access processor for secure search results"
```

### Complete infrastructure in one request

```
"Set up a complete search infrastructure: create a database server, content index
with title/body/tags/author fields, and enable HTML filter, ignore case, and
tokenizer processors"
```

### Manage fields and processors

```
"Add the body field to the content index"
"Remove the sticky field from the content index"
"Add the ignore case and tokenizer processors"
"List available processors for the content index"
```

### Indexing operations

```
"Check the indexing status of all indexes"
"Reindex all items on the content index"
"Clear the content index and rebuild it"
```
