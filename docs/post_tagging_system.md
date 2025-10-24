# post tagging system

## user story

As a forum user, I want to categorize my posts with tags so that I can organize content and help others find relevant posts through tag-based filtering and search.

allow forum users to categorize my posts with tags for content organization purposes and to allow other users to find mine or relevant posts via tag based search and filtering. 

## acceptance criteria

1. I can add comma-separated tags when creating a new post, and the tags are automatically normalized and associated with the post.

new posts allow the addition of comma separated tags, which are automatically associated and linked with the post. 

2. Tags are displayed on each post and are clickable, allowing users to filter posts by that specific tag.
each post has visible and clickable tags which allow users to filter posts with that specific tag
3. I can filter the posts list by selecting a tag from a dropdown, and only posts with that tag are displayed.
users can filter posts by selecting tag(s) from a dropdown menu, displaying only posts with the selected tag(s)
4. The search functionality includes tag names, so I can find posts by searching for tag names.
search functioanlity includes tag names, allowing users to find posts by searching for specific tags. 
5. Empty tags are filtered out, and tag names are properly normalized to ensure consistency across the system.
filter out empty tags, and tag names are sufficiently normalized to ensure system consistency
## mvc components

### models
- **Post Model**: extends existing post model with tag associations
  - `has_many :post_tags, dependent: :destroy`
  - `has_many :tags, through: :post_tags`
  - method: `tag_names=(names)` to handle comma-separated tag input
- **Tag Model**: new model for storing tag information
  - `name:string` (unique, normalized to lowercase)
  - `has_many :post_tags, dependent: :destroy`
  - `has_many :posts, through: :post_tags`
  - validation: presence, uniqueness, normalization
- **PostTag Model**: join table for many-to-many relationship
  - `post_id:integer` (foreign key to posts)
  - `tag_id:integer` (foreign key to tags)
  - unique constraint on `[post_id, tag_id]`

### views
- **Posts Index View**: enhanced to include tag filter dropdown and display tags on each post
- **Post Show View**: display tags below post content with clickable links
- **Post Form Views** (new/edit): add tag input field with comma-separated input
- **Tag Filter Component**: dropdown selector for filtering posts by tag

### controllers
- **PostsController**: enhanced with tag handling
  - `create` action: process tag input and create tag associations
  - `update` action: handle tag updates when editing posts
  - `index` action: add tag filtering and search functionality
- **TagsController** (optional): for tag management if needed
  - `index` action: display popular tags
  - `show` action: display posts for a specific tag

## database schema

```sql
CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_tags (
  id SERIAL PRIMARY KEY,
  post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(post_id, tag_id)
);

CREATE INDEX index_tags_on_name ON tags(name);
CREATE INDEX index_post_tags_on_post_id ON post_tags(post_id);
CREATE INDEX index_post_tags_on_tag_id ON post_tags(tag_id);
```

## implementation notes

tags are normalized to lowercase and trimmed to ensure consistency. tag creation uses `find_or_create_by` to avoid duplicates. tag filtering integrates with existing search functionality. tag display uses a consistent visual style. performance considerations include proper indexing on tag-related queries. user experience includes intuitive tag input with help text about comma separation.
