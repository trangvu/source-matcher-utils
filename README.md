## Source Matching Utils

Commandline tool to index and match data in csv file against data in other csv files

### Requirements

* Ruby 

### Usage

#### help

Command

#### matching

Advance topic to last offset

Options:

```
--OPTION=DEFAULT                    DESCRIPTION

--external                          Path to csv that need to be matched
--external-col                      Column number to be matched (index start at 0)
--crawler                           Path to csv that contains crawler names to match against
--crawler-col                       Column number to match in crawler file (index start at 0)
--source                            Path to csv that contains source names to match against
--source-col                        Column number to match in index file (index start at 0)
```

Example:
```
# source-matcher-utils matching --external=../data/indeed.csv --external-col=1 --crawler=../data/crawler.csv --crawler-col=0 --source=../data/job-source.csv --source-col=0
```

