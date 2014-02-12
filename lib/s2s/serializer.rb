require "json"

module S2S
  module Auth
    # Based on https://gist.github.com/mattetti/7624413
    module JsonSerializer
      def self.load(value)
        begin
          JSON.parse(value)
        rescue JSON::ParserError
          nil
        end
      end
      def self.dump(value)
        JSON.generate(value)
      end
    end
  end
end
