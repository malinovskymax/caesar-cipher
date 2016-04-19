require 'json'

class Caesar
  include ActiveModel::Validations

  MIN_TEXT_LENGTH = 0
  MAX_TEXT_LENGTH = 1000
  ALPHABET = Array('a'..'z')
  WORDS_DELIMITER = ' ' # It's space.

  # Simple unigrams are occurrence probabilities for every letter in english text.
  # Data parsed from (see comment above ADVANCED_UNIGRAMS)
  SIMPLE_UNIGRAMS = {
      'e' => 0.1249, 't' => 0.0928, 'a' => 0.0804, 'o' => 0.0764, 'i' => 0.0757, 'n' => 0.0723, 's' => 0.0651,
      'r' => 0.0628, 'h' => 0.0505, 'l' => 0.0407, 'd' => 0.0382, 'c' => 0.0334, 'u' => 0.0273, 'm' => 0.0251,
      'f' => 0.024,  'p' => 0.0214, 'g' => 0.0187, 'w' => 0.0168, 'y' => 0.0166, 'b' => 0.0148, 'v' => 0.0105,
      'k' => 0.0054, 'x' => 0.0023, 'j' => 0.0016, 'q' => 0.0012, 'z' => 0.0009
  }

  # Advanced unigrams are parsed from data, provided by Peter Norvig (http://norvig.com/mayzner.html)
  # Advanced unigrams are occurrence probabilities of every letter in 3..9-letters long words with
  # respect to letter position within the word.
  # Example structure: { 'e' => { '3' => { '1' => 0.01, '2' => '0.1', '3' => 0.14 } } }
  #                    { letter => { word length =>  {position => possibility, position => possibility, ...} } }
  # Actually, it will expires almost never
  ADVANCED_UNIGRAMS = Rails.cache.fetch('advanced_unigram', expires_in: 1.day) do
    begin
      JSON.parse(File.read(Rails.root.join('data', 'probabilities.min.json')))
    # File not found. In that case method get_avg_entropy_advanced will pass data to get_avg_entropy_simple method.
    rescue Errno::ENOENT
      nil
    end
  end

  attr_accessor :text, :shift, :operation, :best_shift

  validates :operation, inclusion: %w(encrypt decrypt), allow_nil: true
  validates :shift, numericality: true, inclusion: 0..(ALPHABET.length - 1)
  validates :text, presence: true, length: { minimum: MIN_TEXT_LENGTH, maximum: MAX_TEXT_LENGTH }
  validate :must_contain_english_text

  alias :read_attribute_for_serialization :send

  def initialize(args = {})
    @text = args[:text].to_s if args[:text]
    @shift= args[:shift].to_i if args[:shift]
    @operation = args[:operation].to_s if args[:operation]
    @best_shift = 0
  end

  # Returning encrypted/decrypted @text
  # Encrypt/decrypt text according to shift and operation
  def crypt!
    return if @shift.zero?
    encryptor = Hash[ALPHABET.zip(ALPHABET.rotate(@operation == 'decrypt' ? -@shift : @shift))]
    @text = @text.split('').map do |c|
      if /[a-z]/.match(c)
        encryptor[c]
      elsif /[A-Z]/.match(c)
        encryptor[c.downcase].capitalize
      else
        c
      end
    end.join
  end

  # Guessing best shift for decryption using simple or advanced ways to get text's entropy (lower entropy is better).
  # Changing @text and @best_shift
  def guess_shift_and_decrypt!
    analysis_type = select_analysis_type(filtered_text.split(WORDS_DELIMITER))
    min_entropy = 0
    best_text = @text
    @operation = 'decrypt'
    # Since crypt! is destructive, we need to crypt! 26 times with @shift = 1
    @shift = 1
    ALPHABET.length.times do |i|
      current_entropy = analysis_type == :advanced ? get_avg_entropy_advanced(get_perfect_words) : get_avg_entropy_simple(filtered_text)
      # Initialize on first iteration
      min_entropy = current_entropy if i.zero?
      if min_entropy > current_entropy
        @best_shift = i
        best_text = @text
        min_entropy = current_entropy
      end
      crypt!
    end
    # No need to send text back, because it's not encrypted
    @text = @best_shift.zero? ? nil : best_text
  end


  private

  # @text validation
  def must_contain_english_text
    errors.add(:text, 'must be english text') if filtered_text.gsub(WORDS_DELIMITER, '').blank?
  end

  def filtered_text
    @text.gsub(/[^a-z]+/i, WORDS_DELIMITER).strip.downcase
  end

  # Returning array of perfect words (with length within 3..9) for advanced analysis
  def get_perfect_words
    filtered_text.split(WORDS_DELIMITER).reject { |w| !(3..9).include?(w.length) }
  end

  # Receiving array of words ['hello', 'world'], for which we should select best analysis type.
  # Returning symbol :simple or :advanced
  # We can use two types of analysis, advanced and simple, both lowest entropy based.
  # Simple analysis takes into account only overall frequency of occurrences of characters.
  # Advanced analysis trying to make sample more representative, and takes into account
  # frequency of occurrences of characters with respect to word length and character position within the word.
  # Data for advanced analysis taken from Peter Norvig study (http://norvig.com/mayzner.html)
  def select_analysis_type(words)
    perfect_words = get_perfect_words
    if perfect_words.length.to_f / words.length.to_f < 0.5 or perfect_words.length < 4
      # More than a half words are longer or shorter, than perfect range. Or there is less than 4 perfect words.
      :simple
    else
      :advanced
    end
  end

  # Receiving string only contains english letters without spaces 'helloworld'
  # Returning average entropy per char in bits (float positive number) (lower is better)
  def get_avg_entropy_simple(string)
    sum = 0
    string.gsub!(WORDS_DELIMITER, '')
    string.each_char { |c| sum += Math.log2(SIMPLE_UNIGRAMS[c]) }
    -sum / string.length
  end

  # Receiving array of downcased words with length between 3 and 9 ['hello', 'world'] (get_perfect_words)
  # Returning average entropy per char in bits (float positive number) (lower is better)
  # Sometimes, according, to Norvig's research, we got zero possibility of some chars occurrence
  # in specific positions in words with specific length, what will cause
  # sum += Math.log2(0) (-Infinity), and break our calculations. So, to avoid that, we should just skip that iteration.
  def get_avg_entropy_advanced(words)
    # if we can't load advanced unigrams from cache or from file for some reason, pass to get_avg_entropy_simple
    return get_avg_entropy_simple(words.join) unless ADVANCED_UNIGRAMS
    sum = chars_count = 0
    unigrams = ADVANCED_UNIGRAMS
    words.each do |word|
      chars_count += word.length
      (1..word.length).each do |position|
        char = word.at(position - 1)
        next if unigrams[char][word.length.to_s][position.to_s].zero?
        sum += Math.log2(unigrams[char][word.length.to_s][position.to_s])
      end
    end
    -sum / chars_count
  end

end
