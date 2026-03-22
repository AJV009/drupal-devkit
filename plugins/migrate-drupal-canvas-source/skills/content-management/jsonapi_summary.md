# JSON:API Specification Summary

Auto-generated summary of `jsonapi_specification.json`. Consult the full spec for request/response schemas and detailed field definitions.

## Authentication

- **OAuth 2.0** — supports client_credentials, password, authorization_code, and implicit flows
- **CSRF Token** — via `X-CSRF-Token` header (get token from `/session/token`)

## Resource Overview

| Resource | Endpoints | Collection | Entity |
| --- | --- | --- | --- |
| `file/file` | 3 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_archive_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_documents_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_image_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_pdf_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_spinset_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/acquia_dam_video_asset` | 11 | GET, POST | GET, DELETE, PATCH |
| `media/document` | 15 | GET, POST | GET, DELETE, PATCH |
| `media/image` | 15 | GET, POST | GET, DELETE, PATCH |
| `media/remote_video` | 13 | GET, POST | GET, DELETE, PATCH |
| `media/video` | 15 | GET, POST | GET, DELETE, PATCH |
| `node/article` | 18 | GET, POST | GET, DELETE, PATCH |
| `node/person` | 8 | GET, POST | GET, DELETE, PATCH |
| `page` | 6 | GET, POST | GET, DELETE, PATCH |
| `taxonomy/categories` | 7 | GET, POST | GET, DELETE, PATCH |
| `taxonomy/tags` | 7 | GET, POST | GET, DELETE, PATCH |

---

## `file/file`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The timestamp that the file was last changed. |
| `created` | number (utc-millisec) | The timestamp that the file was created. |
| `filemime` | string | The file\'s MIME type. |
| `filename` | string | Name of the file with no path components. |
| `filesize` | integer | The size of the file in bytes. |
| `langcode` | object | The file language code. |
| `status` | boolean | The status of the file, temporary (FALSE) and permanent (TRUE). |
| `uri` | object | The URI to access the file (either local or remote). |

### Relationships

- `uid` → `user--user`

### Endpoints

- `/file/file` — GET, POST
- `/file/file/{entity}` — GET, DELETE, PATCH
- `/file/file/{entity}/relationships/uid` — DELETE, GET, PATCH, POST

## `media/acquia_dam_archive_asset`

### Endpoints

- `/media/acquia_dam_archive_asset` — GET, POST
- `/media/acquia_dam_archive_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_archive_asset/{entity}/acquia_dam_managed_file` — GET
- `/media/acquia_dam_archive_asset/{entity}/relationships/acquia_dam_managed_file` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_archive_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_archive_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_archive_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_archive_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_archive_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_archive_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_archive_asset/{file_field_name}` — POST

## `media/acquia_dam_documents_asset`

### Endpoints

- `/media/acquia_dam_documents_asset` — GET, POST
- `/media/acquia_dam_documents_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_documents_asset/{entity}/acquia_dam_managed_file` — GET
- `/media/acquia_dam_documents_asset/{entity}/relationships/acquia_dam_managed_file` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_documents_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_documents_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_documents_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_documents_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_documents_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_documents_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_documents_asset/{file_field_name}` — POST

## `media/acquia_dam_image_asset`

### Endpoints

- `/media/acquia_dam_image_asset` — GET, POST
- `/media/acquia_dam_image_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_image_asset/{entity}/acquia_dam_managed_image` — GET
- `/media/acquia_dam_image_asset/{entity}/relationships/acquia_dam_managed_image` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_image_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_image_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_image_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_image_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_image_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_image_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_image_asset/{file_field_name}` — POST

## `media/acquia_dam_pdf_asset`

### Endpoints

- `/media/acquia_dam_pdf_asset` — GET, POST
- `/media/acquia_dam_pdf_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_pdf_asset/{entity}/acquia_dam_managed_file` — GET
- `/media/acquia_dam_pdf_asset/{entity}/relationships/acquia_dam_managed_file` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_pdf_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_pdf_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_pdf_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_pdf_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_pdf_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_pdf_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_pdf_asset/{file_field_name}` — POST

## `media/acquia_dam_spinset_asset`

### Endpoints

- `/media/acquia_dam_spinset_asset` — GET, POST
- `/media/acquia_dam_spinset_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_spinset_asset/{entity}/acquia_dam_managed_file` — GET
- `/media/acquia_dam_spinset_asset/{entity}/relationships/acquia_dam_managed_file` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_spinset_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_spinset_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_spinset_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_spinset_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_spinset_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_spinset_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_spinset_asset/{file_field_name}` — POST

## `media/acquia_dam_video_asset`

### Endpoints

- `/media/acquia_dam_video_asset` — GET, POST
- `/media/acquia_dam_video_asset/{entity}` — GET, DELETE, PATCH
- `/media/acquia_dam_video_asset/{entity}/acquia_dam_managed_file` — GET
- `/media/acquia_dam_video_asset/{entity}/relationships/acquia_dam_managed_file` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_video_asset/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_video_asset/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_video_asset/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_video_asset/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/acquia_dam_video_asset/{entity}/thumbnail` — GET
- `/media/acquia_dam_video_asset/{entity}/{file_field_name}` — POST
- `/media/acquia_dam_video_asset/{file_field_name}` — POST

## `media/document`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time the media item was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The time the media item was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |

### Relationships

- `bundle` → `media_type--media_type`
- `categories`
- `media_file` → `file--file`
- `revision_user` → `user--user`
- `tags`
- `thumbnail` → `file--file`
- `uid` → `user--user`

### Endpoints

- `/media/document` — GET, POST
- `/media/document/{entity}` — GET, DELETE, PATCH
- `/media/document/{entity}/categories` — GET
- `/media/document/{entity}/media_file` — GET
- `/media/document/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/categories` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/media_file` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/tags` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/document/{entity}/tags` — GET
- `/media/document/{entity}/thumbnail` — GET
- `/media/document/{entity}/{file_field_name}` — POST
- `/media/document/{file_field_name}` — POST

## `media/image`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time the media item was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The time the media item was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |

### Relationships

- `bundle` → `media_type--media_type`
- `categories`
- `media_image` → `file--file`
- `revision_user` → `user--user`
- `tags`
- `thumbnail` → `file--file`
- `uid` → `user--user`

### Endpoints

- `/media/image` — GET, POST
- `/media/image/{entity}` — GET, DELETE, PATCH
- `/media/image/{entity}/categories` — GET
- `/media/image/{entity}/media_image` — GET
- `/media/image/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/categories` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/media_image` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/tags` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/image/{entity}/tags` — GET
- `/media/image/{entity}/thumbnail` — GET
- `/media/image/{entity}/{file_field_name}` — POST
- `/media/image/{file_field_name}` — POST

## `media/remote_video`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time the media item was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The time the media item was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |

### Relationships

- `bundle` → `media_type--media_type`
- `categories`
- `media_oembed_video`
- `revision_user` → `user--user`
- `tags`
- `thumbnail` → `file--file`
- `uid` → `user--user`

### Endpoints

- `/media/remote_video` — GET, POST
- `/media/remote_video/{entity}` — GET, DELETE, PATCH
- `/media/remote_video/{entity}/categories` — GET
- `/media/remote_video/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/relationships/categories` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/relationships/tags` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/remote_video/{entity}/tags` — GET
- `/media/remote_video/{entity}/thumbnail` — GET
- `/media/remote_video/{entity}/{file_field_name}` — POST
- `/media/remote_video/{file_field_name}` — POST

## `media/video`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time the media item was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The time the media item was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |

### Relationships

- `bundle` → `media_type--media_type`
- `categories`
- `media_video_file` → `file--file`
- `revision_user` → `user--user`
- `tags`
- `thumbnail` → `file--file`
- `uid` → `user--user`

### Endpoints

- `/media/video` — GET, POST
- `/media/video/{entity}` — GET, DELETE, PATCH
- `/media/video/{entity}/categories` — GET
- `/media/video/{entity}/media_video_file` — GET
- `/media/video/{entity}/relationships/bundle` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/categories` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/media_video_file` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/tags` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/thumbnail` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/media/video/{entity}/tags` — GET
- `/media/video/{entity}/thumbnail` — GET
- `/media/video/{entity}/{file_field_name}` — POST
- `/media/video/{file_field_name}` — POST

## `node/article`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time that the node was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The date and time that the content was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `moderation_state` | string | The moderation state of this piece of content. |
| `path` | object | URL alias |
| `publish_on` | number (utc-millisec) | Publish on |
| `publish_state` | string | Publish state |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log` | string | Briefly describe the changes you have made. |
| `revision_timestamp` | number (utc-millisec) | The time that the current revision was created. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |
| `title` | string | Title |
| `unpublish_on` | number (utc-millisec) | Unpublish on |
| `unpublish_state` | string | Unpublish state |

### Relationships

- `author_profile` → `node--person`
- `body`
- `categories`
- `cover_image` → `media--image`
- `media`
- `menu_link`
- `node_type` → `node_type--node_type`
- `related_articles`
- `revision_uid` → `user--user`
- `tags`
- `uid` → `user--user`

### Endpoints

- `/node/article` — GET, POST
- `/node/article/{entity}` — GET, DELETE, PATCH
- `/node/article/{entity}/author_profile` — GET
- `/node/article/{entity}/categories` — GET
- `/node/article/{entity}/cover_image` — GET
- `/node/article/{entity}/media` — GET
- `/node/article/{entity}/related_articles` — GET
- `/node/article/{entity}/relationships/author_profile` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/categories` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/cover_image` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/media` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/menu_link` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/node_type` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/related_articles` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/revision_uid` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/tags` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/relationships/uid` — DELETE, GET, PATCH, POST
- `/node/article/{entity}/tags` — GET

## `node/person`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time that the node was last edited. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `created` | number (utc-millisec) | The date and time that the content was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `langcode` | object | Language |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `moderation_state` | string | The moderation state of this piece of content. |
| `path` | object | URL alias |
| `publish_on` | number (utc-millisec) | Publish on |
| `publish_state` | string | Publish state |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log` | string | Briefly describe the changes you have made. |
| `revision_timestamp` | number (utc-millisec) | The time that the current revision was created. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |
| `title` | string | Display name |
| `unpublish_on` | number (utc-millisec) | Unpublish on |
| `unpublish_state` | string | Unpublish state |

### Relationships

- `bio`
- `first_name`
- `job_title`
- `last_name`
- `menu_link`
- `node_type` → `node_type--node_type`
- `profile_image` → `media--image`
- `revision_uid` → `user--user`
- `uid` → `user--user`

### Endpoints

- `/node/person` — GET, POST
- `/node/person/{entity}` — GET, DELETE, PATCH
- `/node/person/{entity}/profile_image` — GET
- `/node/person/{entity}/relationships/menu_link` — DELETE, GET, PATCH, POST
- `/node/person/{entity}/relationships/node_type` — DELETE, GET, PATCH, POST
- `/node/person/{entity}/relationships/profile_image` — DELETE, GET, PATCH, POST
- `/node/person/{entity}/relationships/revision_uid` — DELETE, GET, PATCH, POST
- `/node/person/{entity}/relationships/uid` — DELETE, GET, PATCH, POST

## `page`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time the page was last edited. |
| `components` | array | Components |
| `created` | number (utc-millisec) | The time the page was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `description` | string | Meta description |
| `include_in_search` | boolean | Indicates whether this page should be excluded from search results. |
| `langcode` | object | Language |
| `metatags` | array | The computed meta tags for the entity. |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |
| `title` | string | Title |

### Relationships

- `image` → `media--image`
- `owner` → `user--user`
- `revision_user` → `user--user`

### Endpoints

- `/page` — GET, POST
- `/page/{entity}` — GET, DELETE, PATCH
- `/page/{entity}/image` — GET
- `/page/{entity}/relationships/image` — DELETE, GET, PATCH, POST
- `/page/{entity}/relationships/owner` — DELETE, GET, PATCH, POST
- `/page/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST

## `taxonomy/categories`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time that the term was last edited. |
| `content_translation_created` | number (utc-millisec) | The Unix timestamp when the translation was created. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `description` | object | Description |
| `langcode` | object | The term language code. |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |
| `weight` | integer | The weight of this term in relation to other terms. |

### Relationships

- `content_translation_uid` → `user--user`
- `parent`
- `revision_user` → `user--user`
- `vid` → `taxonomy_vocabulary--taxonomy_vocabulary`

### Endpoints

- `/taxonomy/categories` — GET, POST
- `/taxonomy/categories/{entity}` — GET, DELETE, PATCH
- `/taxonomy/categories/{entity}/parent` — GET
- `/taxonomy/categories/{entity}/relationships/content_translation_uid` — DELETE, GET, PATCH, POST
- `/taxonomy/categories/{entity}/relationships/parent` — DELETE, GET, PATCH, POST
- `/taxonomy/categories/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/taxonomy/categories/{entity}/relationships/vid` — DELETE, GET, PATCH, POST

## `taxonomy/tags`

### Attributes

| Field | Type | Description |
| --- | --- | --- |
| `changed` | number (utc-millisec) | The time that the term was last edited. |
| `content_translation_created` | number (utc-millisec) | The Unix timestamp when the translation was created. |
| `content_translation_outdated` | boolean | A boolean indicating whether this translation needs to be updated. |
| `content_translation_source` | object | The source language from which this translation was created. |
| `default_langcode` | boolean | A flag indicating whether this is the default translation. |
| `description` | object | Description |
| `langcode` | object | The term language code. |
| `metatag` | array | The computed meta tags for the entity. |
| `metatags` | metatag | The meta tags for the entity. |
| `name` | string | Name |
| `path` | object | URL alias |
| `revision_created` | number (utc-millisec) | The time that the current revision was created. |
| `revision_default` | boolean | A flag indicating whether this was a default revision when it was saved. |
| `revision_log_message` | string | Briefly describe the changes you have made. |
| `revision_translation_affected` | boolean | Indicates if the last edit of a translation belongs to current revision. |
| `status` | boolean | Published |
| `weight` | integer | The weight of this term in relation to other terms. |

### Relationships

- `content_translation_uid` → `user--user`
- `parent`
- `revision_user` → `user--user`
- `vid` → `taxonomy_vocabulary--taxonomy_vocabulary`

### Endpoints

- `/taxonomy/tags` — GET, POST
- `/taxonomy/tags/{entity}` — GET, DELETE, PATCH
- `/taxonomy/tags/{entity}/parent` — GET
- `/taxonomy/tags/{entity}/relationships/content_translation_uid` — DELETE, GET, PATCH, POST
- `/taxonomy/tags/{entity}/relationships/parent` — DELETE, GET, PATCH, POST
- `/taxonomy/tags/{entity}/relationships/revision_user` — DELETE, GET, PATCH, POST
- `/taxonomy/tags/{entity}/relationships/vid` — DELETE, GET, PATCH, POST

---

## Not Available via API

The following are **not exposed** in the JSON:API spec:

- **Menu items** (main, footer, social-media) — no standalone menu endpoints. Only `relationships/menu_link` on nodes (links to User account menu, not navigation menus). Manage via admin UI.
- **Site settings** (site name, logo, favicon) — no config/settings endpoints. Manage via admin UI at `/admin/config/system/site-settings`.
- **URL aliases/redirects** — manage via admin UI at `/admin/config/search/path` and `/admin/config/search/redirect`.
