require 'spec_helper'
 
describe Rspreadsheet::Cell do
  before do 
    book1 = Rspreadsheet.new
    @sheet1 = book1.create_worksheet
    book2 = Rspreadsheet.new($test_filename)
    @sheet2 = book2.worksheets(1)
  end
  it 'contains good row and col coordinates' do
    @cell = @sheet1.cells(1,3)
    @cell.rowi.should == 1
    @cell.coli.should == 3
    @cell.coordinates.should == [1,3]
    @cell = @sheet2.cells(7,2)
    @cell.rowi.should == 7
    @cell.coli.should == 2
    @cell.coordinates.should == [7,2]
  end
  it 'can be referenced by more vars and both are synchronized' do
    @cell = @sheet1.cells(1,1)
    @sheet1[1,1] = 'novinka'
    @cell.value.should == 'novinka'
  end
  it 'can be modified by more ways and all are identical' do
    @cell = @sheet1.cells(2,2)
    @sheet1[2,2] = 'zaprve'
    @cell.value.should == 'zaprve'
    @sheet1.cells(2,2).value = 'zadruhe'
    @cell.value.should == 'zadruhe'
    @sheet1.B2 = 'zatreti'
    @cell.value.should == 'zatreti'
    @sheet1.rows(2).cells(2).value = 'zactvrte'
    @cell.value.should == 'zactvrte'
    @sheet1.rows(2)[2] = 'zapate'
    @cell.value.should == 'zapate'
  end
  it 'can include links' do
    @sheet2.A12.should == '[http://example.org/]'
    @sheet2.cells(12,2).valuexmlfindall('.//text:a').size.should eq 0
    @sheet2.cells(12,1).valuexmlfindall('.//text:a').size.should eq 1
    @sheet2.cells(12,1).valuexmlfindfirst('.//text:a').attributes['href'].should eq 'http://example.org/'
  end
  it 'contains good row and col coordinates even after table:number-columns-repeated cells' do
    @cell = @sheet2.cells(13,5)
    @cell.value.should == 'afterrepeated'
    @cell.rowi.should == 13
    @cell.coli.should == 5
  end
  it 'reports good range of coordinates for repeated cells' do
    @cell = @sheet2.cells(13,2)
    @cell.range.should == (1..4)
    @cell.mode.should == :repeated
  end
  it 'does not accept negative and zero coordinates' do
    @sheet2.cells(0,5).should be(nil)
    @sheet2.cells(2,-5).should be(nil)
    @sheet2.cells(-2,-5).should be(nil)
  end
  it 'has nonempty parents' do
    @cell = @sheet2.cells(13,5)
    @cell.row.should_not be_nil
    @cell.worksheet.should_not be_nil

    @cell = @sheet1.cells(2,2)
    @cell.row.should_not be_nil
    @cell.worksheet.should_not be_nil
  end
  it 'handles relative correctly' do
    @sheet2.cells(3,3).relative(-1,+2).coordinates.should == [2,5]
    @sheet2.cells(3,3).relative(0,0).coordinates.should == [3,3]
  end
  it 'is automatically "unrepeated" on value assignement' do
    @cell = @sheet2.cells(13,2)
    @cell.is_repeated?.should == true
    @cell.value = 'cokoli'
    @cell.is_repeated?.should == false
    @cell.value.should == 'cokoli'
    @sheet2.cells(13,1).should_not == 'cokoli'
    @sheet2.cells(13,3).should_not == 'cokoli'
    @sheet2.cells(13,4).should_not == 'cokoli'
  end
  it 'returns correct type for the cell' do
    @sheet2.cells(1,2).type.should eq :string
    @sheet2.cells(2,2).type.should eq :date
    @sheet2.cells(3,1).type.should eq :float
    @sheet2.cells(3,2).type.should eq :percentage
    @sheet2.cells(4,2).type.should eq :string
    @sheet2.cells(200,200).type.should eq :unassigned
  end
  it 'returns value of correct type' do
    @sheet2[1,2].should be_kind_of(String)
    @sheet2[2,2].should be_kind_of(Date)
    @sheet2[3,1].should be_kind_of(Float)
    @sheet2[3,2].should be_kind_of(Float)
    @sheet2.cells(3,2).type.should eq :percentage
    @sheet2.cells(3,2).guess_cell_type.should eq :percentage
    @sheet2.cells(3,2).guess_cell_type(1).should eq :percentage
    @sheet2[3,2]=0.1
    @sheet2.cells(3,2).type.should eq :percentage
    @sheet2[4,2].should be_kind_of(String)
  end
  it 'is the same object no matter how you access it' do
    @cell1 = @sheet2.cells(5,5)
    @cell2 = @sheet2.rows(5).cells(5)
    @cell1.should equal(@cell2)
  end
  it 'splits correctly cells if written in the middle of repeated group' do
    @cell = @sheet2.cells(4,6)
    @cell.range.should == (4..7)
    @cell.value.should == 7
    
    @cell.value = 'nebesa'
    @cell.range.should == (6..6)
    @cell.value.should == 'nebesa'
    
    @cellA = @sheet2.cells(4,5)
    @cellA.range.should == (4..5)
    @cellA.value.should == 7
    
    @cellB = @sheet2.cells(4,7)
    @cellB.range.should == (7..7)
    @cellB.value.should == 7
  end
  it 'inserts correctly cell in the middle of repeated group' do
    @cell = @sheet2.cells(4,6)
    @cell.range.should == (4..7)
    @cell.value.should == 7
    @cell.coli.should == 6
    
    @sheet2.insert_cell_before(4,6)
    @cell.coli.should == 7
    
    @cellA = @sheet2.cells(4,5)
    @cellA.range.should == (4..5)
    @cellA.value.should == 7
    
    @cellB = @sheet2.cells(4,7)
    @cellB.range.should == (7..8)
    @cellB.value.should == 7
    
    @cell = @sheet2.cells(16,4)
    @cell.range.should == (1..7)
    @cell.value.should == ""
    
    @sheet2.rows(15).range.should == (14..18)
    @sheet2.rows(16).range.should == (14..18)
    @sheet2.rows(17).range.should == (14..18)
    @sheet2.insert_cell_before(16,3)
    @sheet2.cells(16,3).value = 'baf'
    @sheet2.cells(17,3).value.should_not == 'baf'
    @sheet2.rows(15).range.should == (14..15)
    @sheet2.rows(16).range.should == (16..16)
    @sheet2.rows(17).range.should == (17..18)
    
    @cellA = @sheet2.cells(16,1)
    @cellA.range.should == (1..2)
    @cellA.value.should == ""
    
    @cellB = @sheet2.cells(16,5)
    @cellB.range.should == (4..8)
    @cellB.value.should == ""

  end
  it 'inserted has correct class' do # based on real error
    @sheet2.insert_cell_before(1,1)
    @sheet2.rows(1).cells(1).should be_kind_of(Rspreadsheet::Cell)
  end
  it 'can have different formats' do
    @cell = @sheet2.cells(6,3)
    @cell.format.bold.should == true
    @cell = @sheet2.cells(6,4)
    @cell.format.bold.should == false
    @cell.format.italic.should == true
    @cell = @sheet2.cells(6,5)
    @cell.format.italic.should == false
    @cell.format.color.should == '#ff3333'
    @cell = @sheet2.cells(6,6)
    @cell.format.color.should_not == '#ff3333'
    @cell.format.background_color.should == '#6666ff'
    @cell = @sheet2.cells(6,7)
    @cell.format.font_size.should == '7pt'
        
    # after fresh create
    @cell.xmlnode.attributes['style-name'].should_not be_nil
  end
  it 'can set formats of the cells in new file' do
    @cell = @sheet1.cells(1,1)
    @cell.value = '1'
    # bold
    @cell.format.bold.should be_falsey
    @cell.format.bold = true
    @cell.format.bold.should be_truthy
    # italic
    @cell.format.italic.should be_falsey
    @cell.format.italic = true
    @cell.format.italic.should be_truthy
    # color
    @cell.format.color.should be_nil
    @cell.format.color = '#AABBCC'
    @cell.format.color.should eq '#AABBCC'
    # background_color
    @cell.format.background_color.should be_nil
    @cell.format.background_color = '#AABBCC'
    @cell.format.style_name.should_not eq 'cell'
    @cell.format.background_color.should eq '#AABBCC'
    # font_size
    @cell.format.font_size.should be_nil
    @cell.format.font_size = '11pt'
    @cell.format.font_size.should eq '11pt'
  end
  it 'method cells without arguments returns array of cells' do
    @a = @sheet2.rows(1).cells
    @a.should be_kind_of(Array)
    @a.each { |item| item.should be_kind_of(Rspreadsheet::Cell)}
  
  end
  it 'changes coordinates when row inserted above' do
    @sheet1.cells(2,2).detach
    @cell = @sheet1.cells(2,2)
    @cell.rowi.should == 2
    @sheet1.add_row_above(1)
    @cell.rowi.should == 3
  end
  it 'switches to invalid_reference cell when deleted' do
    @sheet1[2,5] = 'nejaka data'
    @cell = @sheet1.cells(2,2)
    @cell.value = 'data'
    @cell.invalid_reference?.should be false
    @cell.delete
    @cell.invalid_reference?.should be true
    expect { @cell.rowi }.to raise_error
    expect { @cell.address }.to raise_error
    
    @sheet1.cells(2,2).type.should == :string
    @sheet1.cells(3,2).type.should == :unassigned
  end
  it 'switches to invalid_reference cell when its row is deleted' do
    @cell = @sheet1.cells(6,2)
    @cell.value = 'data'
    @cell.rowi.should == 6
    @sheet1.rows(6).delete
    expect { @cell.rowi }.to raise_error
    @cell.invalid_reference?.should be true
  end
  it 'has inspect method returning something good' do
    @cell = @sheet1.cells(6,2)
    @cell.value = 'abcde'
    expect(@cell.inspect).to include('abcde','::Cell','6','2','row')
  end
  it 'stores date correctly' do
    @cell = @sheet1.cells(1,1)
    @cell.value= Date.parse('2014-01-02')
    @cell.value.year.should eq 2014
    @cell.value.month.should eq 1
    @cell.value.day.should eq 2
  end
  it 'can be addressed by even more ways and all are identical' do
    @cell = @sheet1.cells(2,2)
    @sheet1.cells('B2').value = 'zaseste'
    @sheet1.cells('B2').value.should == 'zaseste'
    @cell.value.should == 'zaseste'
    @sheet1.cells(2,'B').value.should == 'zaseste'
    @sheet1.cells(2,'B').value = 'zasedme'
    @cell.value.should == 'zasedme'
    @sheet1['B2'].should == 'zasedme'
    @sheet1['B2'] = 'zaosme'
    @cell.value.should == 'zaosme'
    
    @sheet2.cells('F2').should be @sheet2.cells(2,6)
    @sheet2.cells('BA177').should be @sheet2.cells(177,53)
    @sheet2.cells('ADA2').should be @sheet2.cells(2,781)
  end
  it 'setting format in new file detaches the cell' do
    @cell = @sheet1.cells(1,1)
    # bold
    @cell.format.bold.should be_falsey
    @cell.format.bold = true
    @cell.format.bold.should be_truthy
    @cell.type.should eq :regular
  end
end






