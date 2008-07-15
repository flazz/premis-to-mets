require "rexml/document"

def pid(type, value)
  
end

open "premis/case3.xml" do |io|
  doc = REXML::Document.new io.read
  
  # all objects must be represented
  representations = []
  doc.elements.each("//object[@xsi:type='representation'][relationship/relationshipType='Structural']")  do |object| 
    
    related_object_ids = []
    object.elements.each('relationship/relatedObjectIdentification') do |related_object|
      related_object_ids << { :type => related_object.elements['relatedObjectIdentifierType'].text,
        :value => related_object.elements['relatedObjectIdentifierValue'].text }
    end
    
    representations << {
      :type => object.elements['objectIdentifier/objectIdentifierType'].text,
      :value => object.elements['objectIdentifier/objectIdentifierValue'].text,
      :related => related_object_ids
    }
    
  end
  
  doc.elements.each("//object[@xsi:type='file' or @xsi:type='bitstream']") do |object|
    type = object.elements['objectIdentifier/objectIdentifierType'].text
    value = object.elements['objectIdentifier/objectIdentifierValue'].text
    representations
  end
  
end