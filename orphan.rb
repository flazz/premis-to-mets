require "rexml/document"

def all_objects_represented?(doc)
  represented_objects = []
  doc.elements.each("//object[@xsi:type='representation'][relationship/relationshipType='Structural']")  do |object| 
    
    object.elements.each('relationship/relatedObjectIdentification') do |related_object|      
      represented_objects << { 
        :type => related_object.elements['relatedObjectIdentifierType'].text,
        :value => related_object.elements['relatedObjectIdentifierValue'].text 
      }
    end
    
  end
  
  doc.elements.each("//object[@xsi:type='file' or @xsi:type='bitstream']") do |object|
    type = object.elements['objectIdentifier/objectIdentifierType'].text
    value = object.elements['objectIdentifier/objectIdentifierValue'].text
    
    unless !represented_objects.any? { |object| object[:type] == type && object[:value] == value }
      raise "object not represented: #{value}, of type #{type}"
    end
    
  end  
end

open "premis/case3.xml" do |io|
  doc = REXML::Document.new io.read
  
  # all objects are represented
  all_objects_represented? doc
  
  # events have at least one agent
  # events have at least one object
  
  # agents have at least one event
end