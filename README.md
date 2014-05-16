# rspreadsheet

rspreadsheet - manipulating spreadsheets with Ruby. Read, modify, write or create new OpenDocument Spreadsheet files from ruby code.

## Status

*This project is in its brainstorming phase.* Nothing is implemented yet, the documentation now serves as a list of intentions. Please submit issues and/or fork the repository if you have more ideas, wishes, etc ... once the coding begins, it will be much more difficult to change syntax.

## Examples
  
```ruby
require 'rspreadsheet'

book = Rspreadsheet.open('./existing_file.ods')
sheet = book.worksheets 'Icecream list'
total = 0

sheet.rows[3..20].each do |row|
  puts 'Icecream name: ' + row[2]
  puts 'Icecream ingredients: ' + row[3]
  puts "I ate this " + row[4] + ' times'
  total += row[4]
end

sheet[21,3] = 'Total:'
sheet[21,4] = total

sheet.rows[21].format.bold = true

book.save

```

This is the basic functionality. However rspreadsheet should allows lots of alternative syntax, like described in [GUIDE.md](GUIDE.md)

## Installing

To install the gem run the following

    gem install rspreadsheet

## Motivation

This project arised from the necessity. Alhought it is not true that there are no ruby gems allowing to acess OpenDOcument spreadsheet, I did not find another decent one which would suit my needs. Most of them also look abandoned and inactive. I have investigated these options:

  * [ruby-ods](https://github.com/yalab/ruby-ods) - this one seems as if it never really started
  * [rodf](https://github.com/thiagoarrais/rodf)- this only server as builder, it can not read existing files
  * [rods](http://www.drbreinlinger.de/ruby/rods/) - this is pretty ok, but it has terrible syntax. I first thought of writing wrapper around it, but it turned to be not so easy. Also last commit is 2 years old.
  * [rubiod](https://github.com/netoctone/rubiod) - this one is quite ok, the syntax is definitely better that in rods, but it seems also very abandoned. This is a closest match.
  * [spreadsheet](https://github.com/zdavatz/spreadsheet) - this does not work with OpenDocument and even with Excel has issues in modyfying document. However since it is supposedly used, and has quite good syntax it might be inspirative.







