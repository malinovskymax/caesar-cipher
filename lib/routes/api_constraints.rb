module Routes

  class ApiConstraints
    def initialize(options = nil)
      if options
        @version = options[:version]
        @default = options[:default]
      end
    end

    def matches?(req)
      @default || req.headers['Accept'].include?("api.caesar-cipher.v#{@version}")
    end
  end

end
