## Gym Jones Training Plan Parser

Saves each training plan to a plain text file in whatever directory the
script is run from.

```ruby
require 'parser'
parser = GymJonesParser::Client.new(SALVATION_LOGIN, SALVATION_PASSWORD)
parser.parse!
```
