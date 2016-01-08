# BqFakeView
[![Gem Version](https://badge.fury.io/rb/bq_fake_view.svg)](https://badge.fury.io/rb/bq_fake_view)

This gem create Static SQL View on Google Bigquery from Hash data.

It is main purpose to create fake data for testing.

Inspired by [BigQuery で無からリレーションを出現させる - Qiita](http://qiita.com/yancya/items/9af89b6f8d7975ef5892 "BigQuery で無からリレーションを出現させる - Qiita").

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bq_fake_view'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bq_fake_view

## Usage

```ruby
bq_fake_view = BqFakeView.new(Google::Auth.get_application_default(["https://www.googleapis.com/auth/bigquery"]))

data = [
  {foo: 1, bar: "bar", time: Time.now},
  {foo: 2, bar: nil, time: Time.now}
]
schema = [
  {name: "foo", type: "INTEGER"},
  {name: "bar", type: "STRING"},
  {name: "time", type: "TIMESTAMP"}
]
bq_fake_view.create_view("your_project_id", "your_dataset_id", "test_data", data, schema)
# =>
# create "test_data" view.
# view query is
# SELECT * FROM (SELECT 1 as foo, "bar" as bar, TIMESTAMP('2016-1-8 10:02:01') as time), (SELECT 2 as foo, CAST(NULL as STRING) as bar, TIMESTAMP('2016-1-8 10:02:01') as time)

bq_fake_view.view_query(data, schema) # => return Query string used by View definition
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/bq_fake_view.

