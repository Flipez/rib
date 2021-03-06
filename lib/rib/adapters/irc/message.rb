# coding: utf-8

class RIB::Adapters::IRC
  
  class Message < Struct.new(:prefix, :user, :source, :command, :params, :data)

    ##
    # regular expression for parsing a message received by the server.

    RE = / \A
    (?::((?:([^!]+)!)?\S+)\s)?  # prefix and user
    ([A-Za-z]+|\d{3})           # command
    ((?:\s[^:]\S+)*)            # params, minus last
    (?:\s:?(?>(.*)))?           # data
    \Z /x


    ##
    # Parse a received IRC message string into a handy object.
    #
    # @param msg [String] message to parse
    #
    # @return [Message]

    def self.parse(msg = '')
      raise(RIB::MalformedMessageError, msg) unless msg.to_s =~ RE

      prefix, user, command, params = $1, $2, $3, $4.split + [$5].compact
      source = unless params[0].to_s.empty?
                 params[0].to_s[/\A#.*/] || user
               end

      new(prefix, user, source, command, params, params.last)
    end


    ##
    # Convert into {RIB::Message} so it can be passed to a 
    # {RIB::MessageHandler}.
    #
    # @return [RIB::Message]

    def to_rib_msg
      RIB::Message.new(self.data, self.user, self.source)
    end

  end

end

