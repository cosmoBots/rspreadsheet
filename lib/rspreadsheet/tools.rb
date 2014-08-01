module Rspreadsheet

# this module contains methods used bz several objects
module Tools
  # converts cell adress like 'F12' to pair od integers [row,col]
  def self.convert_cell_address(*coords)
    if coords.length == 1
      coords[0].match(/^([A-Z]{1,3})(\d{1,8})$/)
      colname = $~[1]
      rowname = $~[2]
    elsif coords.length == 2
      colname = coords[0]
      rowname = coords[1]
    else
      raise 'Wrong number of arguments'
    end
      
    colname=colname.rjust(3,'@')
    col = (colname[-1].ord-64)+(colname[-2].ord-64)*26+(colname[-3].ord-64)*26*26
    row = rowname.to_i
    return [row,col]
  end
  def self.get_namespace(prefix)
    ns_array = {
      'office'=>"urn:oasis:names:tc:opendocument:xmlns:office:1.0",
      'style'=>"urn:oasis:names:tc:opendocument:xmlns:style:1.0",
      'text'=>"urn:oasis:names:tc:opendocument:xmlns:text:1.0",
      'table'=>"urn:oasis:names:tc:opendocument:xmlns:table:1.0",
      'draw'=>"urn:oasis:names:tc:opendocument:xmlns:drawing:1.0",
      'fo'=>"urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0",
      'xlink'=>"http://www.w3.org/1999/xlink",
      'dc'=>"http://purl.org/dc/elements/1.1/",
      'meta'=>"urn:oasis:names:tc:opendocument:xmlns:meta:1.0",
      'number'=>"urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0",
      'presentation'=>"urn:oasis:names:tc:opendocument:xmlns:presentation:1.0",
      'svg'=>"urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0",
      'chart'=>"urn:oasis:names:tc:opendocument:xmlns:chart:1.0",
      'dr3d'=>"urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0",
      'math'=>"http://www.w3.org/1998/Math/MathML",
      'form'=>"urn:oasis:names:tc:opendocument:xmlns:form:1.0",
      'script'=>"urn:oasis:names:tc:opendocument:xmlns:script:1.0",
      'ooo'=>"http://openoffice.org/2004/office",
      'ooow'=>"http://openoffice.org/2004/writer",
      'oooc'=>"http://openoffice.org/2004/calc",
      'dom'=>"http://www.w3.org/2001/xml-events",
      'xforms'=>"http://www.w3.org/2002/xforms",
      'xsd'=>"http://www.w3.org/2001/XMLSchema",
      'xsi'=>"http://www.w3.org/2001/XMLSchema-instance",
      'rpt'=>"http://openoffice.org/2005/report",
      'of'=>"urn:oasis:names:tc:opendocument:xmlns:of:1.2",
      'xhtml'=>"http://www.w3.org/1999/xhtml",
      'grddl'=>"http://www.w3.org/2003/g/data-view#",
      'tableooo'=>"http://openoffice.org/2009/table",
      'drawooo'=>"http://openoffice.org/2010/draw",
      'calcext'=>"urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0",
      'loext'=>"urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0",
      'field'=>"urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0",
      'formx'=>"urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0",
      'css3t'=>"http://www.w3.org/TR/css3-text/"
    }
    if @pomnode.nil?
      @pomnode = LibXML::XML::Node.new('xxx')
    end
    if @ns.nil? then @ns={} end
    if @ns[prefix].nil?
      @ns[prefix] = LibXML::XML::Namespace.new(@pomnode, prefix, ns_array[prefix])
    end
    return @ns[prefix]
  end
end
 
end

class Range
  def size
    res = self.end-self.begin+1
    res>0 ? res : 0
  end
end