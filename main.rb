$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require "tfidf"
require "coordinate"
require "pp"
require "kmeans"

# given the name of a text file, 
# return a small snippet of the file
def document_snippet(doc)
  ret = nil
  File.open("./test 90/#{doc}", "r") do |f|
    f.seek(12)
    ret = f.read(50)
  end
  return ret
end

puts "computing tf.idf matrix..."
tfidf = TFIDF.new('./test 90/file*','./test 90/stoplist.txt')
term_doc_matrix = tfidf.term_document_matrix

# Create the "documents" from the rows of the term document matrix
documents = []
threads = []
term_doc_matrix.each_index do |idx|
  threads << Thread.new(idx) do |i|
    document = Coordinate.new(term_doc_matrix[i])
    document.sphere!
    doc = tfidf.num_to_doc(i)
    document.data = "#{doc}: #{document_snippet(doc)}"
    documents << document
  end
end
threads.each {|t| t.join}

# Computer kmeans algorithm
kmeans = KMeans.new(documents, 3)
kmeans.compute
puts kmeans.to_s
