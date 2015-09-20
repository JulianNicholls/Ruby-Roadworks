# Ruby-Roadworks

Split out roadworks part of the [ReallyBigShoe website](http://www.reallybigshoe.co.uk),
re-implemented in Ruby with Sinatra.

## load_roadworks
Reload the roadworks data into the local or tremote database from a specified data file.
See load_roadworks.rb --help for options.

## find_latest
Search for, and optionally download, the latest roadworks data file from the
[DfT data page](https://data.gov.uk/dataset/highways_agency_planned_roadworks).

This is now fixed for the frequent slight variations in filenames.
After downloading, the index file is updated with the date in the filename
and then it can optionally update the local and remote databases directly.
