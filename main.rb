
 [ "sqlite3",
    "pry",
    "merkle_tree",
    "date",
    "digest",
    "json",
    "ecdsa",
    "securerandom",
    "fileutils",
    "base58",
    "bigdecimal",
    "sinatra/base",
    "logger",
    "httparty",
    "./db",
    "./block",
    "./blockchain",
    "./mining",
    "./wallet",
    "./transaction_builder",
    "./wallet_transfer",
    "./node",
    "./pending_transaction",
].each do |lib|
  require lib
end


$logger = Logger.new(STDOUT)

NEO_DEBUG = true

# No arguments to the command means we'll show the user the list of all commands.
if ARGV.size == 0
  $logger.info "Welcome to the melon factory 🍈\n\n"
  $logger.info "Available commands:"
  $logger.info "\t node — Starts a node"
  $logger.info "\t mine — Starts a node that also performs mining"
  $logger.info "\t pry — A runtime developer console for debugging"
  $logger.info "\t submit_random_transactions — Submits a transaction to all peers every second"

  return
end

# Run the required command.

case ARGV.first.to_s.downcase
when "node"
  $db = Melon::DB.new

  blockchain = Melon::Blockchain.new

  Thread.new do
    begin
      loop do
        sleep 5
        blockchain.find_higher_blocks_on_the_network
      end
    rescue => e
      $logger.error e
    end
  end

  Melon::Node.run!



when "mine"
  $db = Melon::DB.new

  # The mining process starts in a thread. This approach isn't the most elegant
  # but it makes it possible to have the entire application run together which
  # is easier for our purpose.
  Thread.new do
    begin
      sleep 2 # A small delay wil lensure Sinatra starts successfully
      Melon::Mining.start
    rescue => e
      $logger.error e
    end
  end

  Melon::Node.run!

when "pry"
  $db = Melon::DB.new
  blockchain = Melon::Blockchain.new

  binding.pry

when "submit_random_transactions"
  mining_wallet = Melon::Wallet.load_or_create("mining")

  loop do
    # The destination address is random as we're only testing.
    destination = Digest::SHA256.hexdigest(SecureRandom.random_number(100000000000).to_s)
    amount = BigDecimal("0.00" + SecureRandom.random_number(10000).to_s)

    transaction = mining_wallet.generate_transaction(
      destination,
      amount.to_s("F"),
      (amount / 100).to_s("F"),
    )
    pp transaction
    $logger.info("ENV['MELON_PEERS'] = #{ENV["MELON_PEERS"].to_s.split(",")}") if NEO_DEBUG
    ENV["MELON_PEERS"].to_s.split(",").each do |peer|
      
      begin
        response = HTTParty.post("http://#{peer}/transactions/submit",
          body: transaction.to_json,
          headers: { "Content-Type": "application/json" },
        )
      rescue => e
        $logger.info("ERROR: HTTParty.post(http://#{peer}/transactions/submit: #{e}")
      end
      if response.code != 200
        $logger.error("Failed submitting transaction: #{response.message}")
      else
        $logger.info("Submitted one transaction to #{peer}")
      end
    end

    sleep 1
  end

else
  raise "Unknown command."
end