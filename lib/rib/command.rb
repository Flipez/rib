# coding: utf-8

require 'rib/helpers'
require 'rib/action'

module RIB

  class Command < Action

    ##
    # Command params
    #
    # @return [Array<Symbol>]

    attr_reader :params


    ##
    # @param [#to_sym] name
    #   name of the Command
    # @param [Symbol] mod_name
    #   name of the Module that Command belongs to
    # @param [Array<Symbol>] params
    #   params that command can take
    # @param [Symbol, Array<Symbol>] protocol
    #   none or several protocols this command is limited to

    def initialize(name, mod_name, params = [], protocol = nil, &block)
      @params   = params.map(&:to_sym)

      super(name, mod_name, protocol, &block)
    end


    ##
    # Call the block mapped to the :on_call action for this Command.
    #
    # @param [String] data message that has been sent
    # @param [String] user user that sent the message
    # @param [String] source source of the message, e.g. the channel
    # @param [Bot] bot the bot which received the message
    #
    # @return [String] response to send back
    # @return [String, String] response and target to send back to
    # @return [nil] if nothing should be sent back

    def call(data, user, source, bot)
      super(msg:    data,
            user:   user,
            source: source,
            params: map_params(data.split[1..-1]),
            bot:    bot)
    end


    private

    ##
    # Map passed values to the params names of the command.
    #
    # @param [Array<String>] data passed params
    #
    # @return [Hash]

    def map_params(data)
      @params.each_with_index.inject({}) do |hash, (name, index)|
        hash.merge(name => data[index])
      end
    end

  end

end
