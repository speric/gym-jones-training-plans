## Gym Jones Training Plan Parser

Saves each training plan to a plain text file in whatever directory the
script is run from.

Install gems:

```
$ gem install mechanize
$ gem install urlify
```

Open up `irb`:

```ruby
require 'parser'

parser = GymJonesParser::Client.new(SALVATION_LOGIN, SALVATION_PASSWORD)

parser.parse_training_plans! # All Salvation training plans
parser.parse_knowledge!      # All Knowledge articles, with images
```

Not pretty but just needs to work once. :metal:
