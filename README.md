# FastPage
`FastPage` applies the MySQL "deferred join" optimization to your ActiveRecord offset/limit queries. Potentially making your pagination much faster. ⚡️

## Usage

Add `fast_page` to your Gemfile.

```ruby
gem 'fast_page'
```

You can then use the `fast_page` method on any ActiveRecord::Relation that is using offset/limit.

### Example
Here is a slow pagination query:
```ruby
Post.all.order(created_at: :desc).limit(25).offset(100)
# Post Load (1228.7ms)  SELECT `posts`.* FROM `posts` ORDER BY `posts`.`created_at` DESC LIMIT 25 OFFSET 100
```

Add `.fast_page` to your slow pagination query. It breaks it up into two, much faster queries.
```ruby
Post.all.order(created_at: :desc).limit(25).offset(100).fast_page
# Post Pluck (456.9ms)  SELECT `posts`.`id` FROM `posts` ORDER BY `posts`.`created_at` DESC LIMIT 25 OFFSET 100 
# Post Load (0.4ms)  SELECT `posts`.* FROM `posts` WHERE `posts`.`id` IN (1271528, 1271527, 1271526, 1271525, 1271524, 1271523, 1271522, 1271521, 1271520, 1271519, 1271518, 1271517, 1271516, 1271515, 1271514, 1271512, 1271513, 1271511, 1271510, 1271509, 1271508, 1271507, 1271506, 1271505, 1271504) ORDER BY `posts`.`created_at` DESC
```

## Compatible pagination libraries
`FastPage` has been tested and works with these existing popular pagination gems. If you try it with any other gems, please let us know!

### Kaminari
Add `.fast_page` to the end of your existing [Kaminari](https://github.com/kaminari/kaminari) pagination queries.

```ruby
Post.all.page(5).per(25).fast_page
```

### Pagy
In any controller that you want to use `fast_page`, add the following method. This will modify the query [Pagy](https://github.com/ddnexus/pagy) uses when retrieving the records.

```ruby
def pagy_get_items(collection, pagy)
  collection.offset(pagy.offset).limit(pagy.items).fast_page
end
```


## How this works

The most common form of pagination is implemented using LIMIT and OFFSET.

In this example, each page returns 50 blog posts. For the first page, we grab the first 50 posts. On the 2nd page we grab 100 posts and throw away the first 50. As the `OFFSET` increases, each additional page becomes more expensive for the database to serve.

```sql
-- Page 1
SELECT * FROM posts ORDER BY created_at DESC LIMIT 50;
-- Page 2
SELECT * FROM posts ORDER BY created_at DESC LIMIT 50 OFFSET 50;
-- Page 3
SELECT * FROM posts ORDER BY created_at DESC LIMIT 50 OFFSET 100;
```

This method of pagination works well until you have a large number of records. The later pages become very expensive to serve. Because of this, applications will often have to limit the maximum number of pages they allow users to view or swap to cursor based pagination.

### Deferred join technique

[High Performance MySQL](https://learning.oreilly.com/library/view/high-performance-mysql/9781492080503/) recommends using a "deferred join" to increase the efficiency of LIMIT/OFFSET pagination for large tables.

```sql
SELECT * FROM posts 
INNER JOIN(select id from posts ORDER BY created_at DESC LIMIT 50 OFFSET 10000) 
AS lim USING(id);
```

Notice that we first select the ID of all the rows we want to show, then the data for those rows. This technique works "because it lets the server examine as little data as possible in an index without accessing rows."

The FastPage gem makes it easy to apply this optimization to any `ActiveRecord::Relation` using offset/limit.

To learn more on how this works, check out this blog post: [Efficient Pagination Using Deferred Joins](https://aaronfrancis.com/2022/efficient-pagination-using-deferred-joins)

## When should I use this?
`fast_page` works best on pagination queries that include an `ORDER BY`. It becomes more effective as the page number increases. You should test it on your application's data to see how it improves your query times.

Because `fast_page` runs 2 queries instead of 1, it is very likely a bit slower for early pages. The benefits begin as the user gets into deeper pages. It's worth testing to see at which page your application gets faster from using `fast_page` and only applying to your queries then.

```ruby
posts = Post.all.page(params[:page]).per(25)
# Use fast page after page 5, improves query performance
posts = posts.fast_page if params[:page] > 5
```

## Thank you :heart:
This gem was inspired by [Hammerstone's `fast-paginate` for Laravel](https://github.com/hammerstonedev/fast-paginate) and [@aarondfrancis](https://github.com/aarondfrancis)'s excellent blog post: [Efficient Pagination Using Deferred Joins](https://aaronfrancis.com/2022/efficient-pagination-using-deferred-joins). We were so impressed with the results, we had to bring this to Rails as well.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/planetscale/fast_page. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/planetscale/fast_page/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastPage project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/planetscale/fast_page/blob/main/CODE_OF_CONDUCT.md).
