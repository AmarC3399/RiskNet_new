class CardNumber

  attr_reader :card_length, :masked_card_number, :bin, :last_four, :hashed_value

  ##
  # FIXME only used in dev benchmarking. remove!
  # Returns the number of milliseconds taken.
  def self.benchmark num_iterations=10000
    start = Time.zone.now
    
    num_iterations.times do
        # fake card number
        CardNumber.new "5510-0682-7318-5327"
    end
    
    finish = Time.zone.now
    
    return ((finish - start) * 1000.0)
  end

  def initialize(number)
    # puts " #{Time.zone.now.to_i}:inside#{__method__} for CardNUMBER"
    @number = number.to_s.gsub('-', '')
          @bin = @number[0..5]
    @last_four = @number[-4..-1]
    @card_length = @number.size || 10
    @masked_card_number = "#{@bin}#{'*'*(@card_length-10)}#{@last_four}"

    calculate_card_hash
  end

  private

  def calculate_card_hash
    @hashed_value = Digest::SHA384.hexdigest "#{@number}#{RiskNet.hashing_salt}"
  end
  # def benchmark_cards
  #   puts "512 bit with 128 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(128)}}
  #   puts "512 bit with 256 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(256)}}
  #   puts "512 bit with 512 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(512)}}
  #   puts "256 bit with 128 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.hexdigest SecureRandom.hex(128)}}
  #   puts "256 bit with 256 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.hexdigest SecureRandom.hex(256)}}
  #   puts "256 bit with 512 bytes salt"
  #   puts Benchmark.measure {10000.times{ Digest::SHA2.hexdigest SecureRandom.hex(512)}}
  # end
  #
  # def benchcards10
  #   Benchmark.bmbm do |x|
  #     x.report("512 bit with 128 bytes salt") { 10.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(128)} }
  #     x.report("512 bit with 256 bytes salt") { 10.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(256)} }
  #     x.report("512 bit with 512 bytes salt") { 10.times{ Digest::SHA2.new(512).hexdigest SecureRandom.hex(512)} }
  #     x.report("256 bit with 128 bytes salt") { 10.times{ Digest::SHA2.hexdigest SecureRandom.hex(128)} }
  #     x.report("256 bit with 256 bytes salt") { 10.times{ Digest::SHA2.hexdigest SecureRandom.hex(256)} }
  #     x.report("256 bit with 512 bytes salt") { 10.times{ Digest::SHA2.hexdigest SecureRandom.hex(512)} }
  #   end
  # end
end