require 'rubygems'
require 'itext'

import com.lowagie.text.pdf.PdfWriter
import com.lowagie.text.Document
import com.lowagie.text.Paragraph

file = File.open('Hello.pdf', 'w')
document = Document.new
writer = PdfWriter.get_instance(document, file.to_outputstream)
paragraph = Paragraph.new('Hello iText!')

document.open
document.add(paragraph)
document.close
