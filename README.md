# DeepBlame

Look at the blame before the blame (before the blame...).

Bit of an experiment. No tests, you might die.

## Installation

gem install deep_blame

## Usage

deep_blame path line_number
deep_blame path start_line,end_line
deep_blame path line_number --display=ids

### Display Options

* ids (space separated list of ids)
* commits (fairly readable list of commits)
* full (shows whole, multi-line commit message)
* default (full commit messages, linebreaks removed)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
