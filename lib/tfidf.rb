require "array_hacks.rb"
require "string_hacks.rb"

class TFIDF
  attr_reader :word_list, :term_document_matrix

  def initialize(dir_glob, stoplist)
    @word_list = Hash.new # This is our main wordlist
    @documents = Hash.new # Let's keep track of each docs' sizes
    @stop_list = File.read(stoplist).split # Words that don't count

    Dir[dir_glob].each do |document|
      # Let's read that document and get the words
      words_in_document = File.read(document).split_with_index(' ')
      # We want to remember this document's size. We'll need it later.
      @documents[document] = words_in_document.size
      # For every word in this document
      words_in_document.each do |word, location|
        word.stem! # we do some basic stemming
        # Let's add it to our "word list" 
        # along with what document it came from
        # and where in the document we saw it
        add(word, document, location) unless word_does_not_belong(word)
      end
    end
    @words_hash = create_words_hash()
    @term_document_matrix = compute_term_document_matrix
  end

  def compute_term_document_matrix
    words_array = @word_list.sort
    # words array is like this:
    # [["brown", {"./test2/file01.txt"=>[6], "./test2/file02.txt"=>[4]}],
    #  ["dog", {"./test2/file01.txt"=>[12], "./test2/file02.txt"=>[0]}],
    #  ["jason", {"./test2/file02.txt"=>[10]}],
    #  ["quick", {"./test2/file01.txt"=>[0]}]]
    td_matrix = Array.new(@documents.size) { Array.new(words_array.size) { 0 } }
    threads = []
    words_array.each do |entry|
      word = entry[0]
      docs = entry[1].keys.map { |doc| doc }
      docs.each do |doc|
        threads << Thread.new(word, doc) do |w, d|
          td_matrix[doc_to_num(d)][word_to_num(w)] = tfidf(w, d)
        end
      end
    end
    threads.each {|t| t.join}
    return td_matrix
  end

  def word_to_num(s)
    @words_hash[s]
  end

  def num_to_word(n)
    @words_hash.invert[n]
  end

  def doc_to_num(s)
    s.scan(/\d\d/).last.to_i-1
  end

  def num_to_doc(n)
    "file%02d.txt" % (n+1)
  end

:private
  def create_words_hash
    words = @word_list.sort.map { |x| x.first }
    words.to_hash_keys { |x| words.index(x) }
  end

  # When we add an entry to a wordlist, we want to know
  # 1. The word itself
  # 2. What document it came from
  # 3. Where in that document is the word located
  def add(word, document, location)
    @word_list[word] = Hash.new if @word_list[word].nil?
    @word_list[word][document] = Array.new if @word_list[word][document].nil?
    @word_list[word][document] << location
  end

  # Let's not include empty, null, or words in the stop list
  def word_does_not_belong(word)
    word.nil? || word.empty? || @stop_list.index(word)
  end

  # document frequency: the number of documents in the collection in which the term occurs
  def df(t)
    @word_list[t].size
  end

  # inverse document frequency: idf is a measure of the informativeness of the term.
  # We use [log(N/dft)] instead of [N/dft] to “dampen” the
  # effect of idf.
  def idf(t)
    Math.log10(@documents.size.to_f/df(t).to_f)
  end

  # term frequency: number of times that t occurs in d
  def tf(t, d)
    begin
      raise "wordlist doesn't contain #{t}" if @word_list[t].nil?
      raise "#{t} doesn't appear in #{d}" if @word_list[t][d].nil?
      @word_list[t][d].size
    rescue Exception => e
      raise "Error in tf: #{t}, #{d} #{e}\n"
    end
  end

  # log frequency weight: The log frequency weight of term t in d
  def w(t, d)
    tf(t, d) > 0 ? 1 + Math.log10(tf(t, d)) : 0
  end

  # The tf.idf weight of a term is the product of its 
  # tf weight and its idf weight.
  def tfidf(t, d)
    w(t, d) * idf(t)
  end
end