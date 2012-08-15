# Cachex

This gem is only proof of concept and it is not safe for use in production.

## Idea

This gem is inspired by excellent [Cashier](https://github.com/twinturbo/cashier) gem. I wanted to take it a step further and try to automate tag dependency generation.

I had this scenario in mind:

* Blog has many posts
* Each post has an author (user)
* Each post has many comments
* Each comment has its own author (user)

Each model has its own partial. Inside `_post` partial we have `_user` partial that renders post's author. `_post` partial also include many `_comment` partials. Each `_comment` partial have author's name displayed in it.

We're also using fragment caching in order to cache entire post for faster serving. The burning question is: **what happens if user decides to change its name (or perhaps, more commonly, an avatar)?**. We have to invalidate every cached partial that displayed that user. How do we do that?

If we're using auto-expiring key strategy the only way to accomplish this would be to `touch` **everything** that has to do with that user. That just doesn't make any sense.

If we're using tag-based strategy, then we would need to manually tag every fragment with all users that have to do something with it (even users from its comments). Such approach is going to be very hard when we get to deeply nested partials. Top most partial will have to be aware of **all dependencies** down to the deepest one.

And finally, my solution: **to automatically extract all dependencies from all sub-partials and to store them to help cache invalidation**.

## Example

Here is how the example above is implemented with `cachex`.

We have `_post` partial defined like this:


    <%= cachex dom_id(post) do %>
      <article class="post">
        <h1><%= post.title %></h1>
        <p>Author: <%= render post.user %></p>
        
        <section class="comments">
          <h3>Comments:</h3>
          <%= render post.comments %>
        </section>
      </article>
    <% end %>

Please note that instead of using `cache` we're using `cachex` helper method. We need to pass at least one argument which is the key for given record. It is good practice to use something that can be easily generated and parsed, so `dom_id` method will do the job.

The rest is just good old rails partial. From it, we're rendering `_user` partial to output post author, and multiple `_comment` partials.

Here is how `_user` partial looks like:


    <%= cachex dom_id(user) do %>
      <span class="user"><%= user.name %></span>
    <% end %>

Again, nothing special to it. Just displaying the user name.

And, here is how the `_comment` partial looks like:


    <%= cachex dom_id(comment), "user_#{comment.user_id}" do %>
      <article class="comment">
        <p><%= comment.body %></p>
        <p>Author: <%= comment.user.name %></p>
      </article>
    <% end %>

You notice that we've passed second parameter to `cachex` call. Actually, you may pass as many as you like. These are keys that current partial depends on. In our case it depends on comment's author. We could have just rendered the user partial here as well, but just wanted to demonstrate that you can also pass dependencies manually.

Now comes the magic. First time this gets rendered, post will aggregate all dependencies from all sub-partials. In our case post will be tagged with following dependencies: 

* It's author
* All of its comments
* All of its comment authors

**If any of these keys expire, post will expire as well!** 

For example, if one of the author's of post comment changes its name, following will happen:

* Post fragment starts regenerating
* Author fragment is read from cache
* All comments (but the one with changed author) is read from cache
* The comment with changed author re-renders
* Dependencies are aggregated again and re-applied
* Post gets cached

`Cachex` stores dependencies in `REDIS` in both directions and it uses sets to manage them, so it works really fast.


## Installation

Add this line to your application's Gemfile:

    gem 'cachex'

And then execute:

    $ rails generate cachex:install


## Author

Developed by Milovan Zogovic.