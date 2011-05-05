module ComfortableMexicanSofa
  VERSION = begin 
    IO.read(File.join(File.dirname(__FILE__), '/../../VERSION')).chomp
  rescue
    'UNKNOWN'
  end
end