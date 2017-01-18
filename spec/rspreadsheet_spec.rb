require 'spec_helper'
using ClassExtensions if RUBY_VERSION > '2.1'

describe Rspreadsheet do
  before do
    @tmp_filename = '/tmp/testfile.ods'        # delete temp file before tests
    File.delete(@tmp_filename) if File.exists?(@tmp_filename)
  end
  after do
    File.delete(@tmp_filename) if File.exists?(@tmp_filename) # delete temp file after tests
  end
  
  it 'can open ods testfile and reads its content correctly' do
    book = Rspreadsheet.new($test_filename)
    s = book.worksheets(1)
    (1..10).each do |i|
      s[i,1].should === i
    end
    s[1,2].should === 'text'
    s[2,2].should === Date.new(2014,1,1)
  end
  it 'can open and save file, and saved file has same cells as original' do
    
    book = Rspreadsheet.new($test_filename)     # open test file
    book.save(@tmp_filename)                    # and save it as temp file
    
    book1 = Rspreadsheet.new($test_filename)   # now open both again
    book2 = Rspreadsheet.new(@tmp_filename)
    @sheet1 = book1.worksheets(1)
    @sheet2 = book2.worksheets(1)
    
    @sheet1.nonemptycells.each do |cell|       # and test identity
      @sheet2[cell.rowi,cell.coli].should == cell.value
    end
  end

  it 'can open and save file, and saved file is exactly same as original' do
    book = Rspreadsheet.new($test_filename)    # open test file
    book.save(@tmp_filename)                    # and save it as temp file
    
    # now compare them
    @content_xml1 = Zip::File.open($test_filename) do |zip|
      LibXML::XML::Document.io zip.get_input_stream('content.xml')
    end
    @content_xml2 = Zip::File.open(@tmp_filename) do |zip|
      LibXML::XML::Document.io zip.get_input_stream('content.xml')
    end
    
    @content_xml2.root.first_diff(@content_xml1.root).should be_nil
    @content_xml1.root.first_diff(@content_xml2.root).should be_nil
    
    @content_xml1.root.should == @content_xml2.root
  end

  it 'when open and save file modified, than the file is different' do
    book = Rspreadsheet.new($test_filename)    # open test file
    book.worksheets(1).rows(1).cells(1).value.should_not == 'xyzxyz'
    book.worksheets(1).rows(1).cells(1).value ='xyzxyz'
    book.worksheets(1).rows(1).cells(1).value.should == 'xyzxyz'
    
    book.save(@tmp_filename)                    # and save it as temp file
    
    # now compare them
    @content_doc1 = Zip::File.open($test_filename) do |zip|
      LibXML::XML::Document.io zip.get_input_stream('content.xml')
    end
    @content_doc2 = Zip::File.open(@tmp_filename) do |zip|
      LibXML::XML::Document.io zip.get_input_stream('content.xml')
    end
    @content_doc1.eql?(@content_doc2).should == false
  end
  it 'can create file' do
    book = Rspreadsheet.new
  end
  it 'can create new worksheet' do
    book = Rspreadsheet.new
    book.create_worksheet
  end
  it 'examples from README file are working' do
    book = Rspreadsheet.open($test_filename)
    sheet = book.worksheets(1)
    sheet.B5 = 'cell value'
    
    sheet.B5.should eq 'cell value'
    sheet[5,2].should eq 'cell value'
    sheet.rows(5).cells(2).value.should eq 'cell value'
    
    expect {
      sheet.F5 = 'text'
      sheet[5,2] = 7
      sheet.cells(5,2).value = 1.78
      
      sheet.cells(5,2).format.bold = true
      sheet.cells(5,2).format.background_color = '#FF0000'
    }.not_to raise_error

    sheet.rows(4).cellvalues.sum.should eq 4+7*4
    sheet.rows(4).cells.sum{ |cell| cell.value.to_f }.should eq 4+7*4

    total = 0
    sheet.rows[0..9].each do |row|
      expect {"Adding number #{row[1]} to the result" }.not_to raise_error
      total += row[1].to_f
    end
    total.should eq 55
  end
  it 'examples from advanced syntax GUIDE are working' do
    def p(*par); end # supress p in the example
    expect do 
      book = Rspreadsheet::Workbook.new
      sheet = book.create_worksheet 'Top icecreams'

      sheet[1,1] = 'My top 5'
      p sheet[1,1].class # => String
      p sheet[1,1] # => "My top 5"
      
      # These are all the same values - alternative syntax
      p sheet.rows(1).cells(1).value
      p sheet.cells(1,1).value
      p sheet.A1
      p sheet[1,1]
      p sheet['A1']
      p sheet.cells('A1').value
      
      # How to inspect/manipulate the Cell object
      sheet.cells(1,1) # => Rspreadsheet::Cell
      sheet.cells(1,1).format
      sheet.cells(1,1).format.font_size = '15pt'
      sheet.cells(1,1).format.bold = true
      p sheet.cells(1,1).format.bold? # => true
      
      # There are the same assigmenents
      value = 1.234
      sheet.A1 = value
      sheet[1,1]= value
      sheet.cells(1,1).value = value
      
      p sheet.A1.class # => Rspreadsheet::Cell
      
      # relative cells
      sheet.cells(4,7).relative(-1,0) # => cell 3,7
      
      # build the top five list (these features are not implemented yet)
#       (1..5).each { |i| sheet[i,1] = i }
#       sheet.columns(1).format.bold = true
#       sheet.cells[2,1..5] = ['Vanilla', 'Pistacia', 'Chocolate', 'Annanas', 'Strawbery']
#       sheet.columns(1).cells(1).format.color = :red
      
      book.save('/tmp/testfile.ods')
    end.not_to raise_error
  end
  it 'can save file to io stream and the content is the same as when saving to file', :skip do
    book = Rspreadsheet.new($test_filename)    # open test file
    
    file = File.open(@tmp_filename, 'w')        # and save the stream to @tmp_filename
    file.write(book.save_to_io)
    file.close
    
    book1 = Rspreadsheet.new($test_filename)   # now open both again
    book2 = Rspreadsheet.new(@tmp_filename)
    @sheet1 = book1.worksheets(1)
    @sheet2 = book2.worksheets(1)
    
    @sheet1.nonemptycells.each do |cell|       # and test if they are identical
      @sheet2[cell.rowi,cell.coli].should == cell.value
    end
  end
end




























