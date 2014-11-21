# coding: utf-8

require 'rib'


##
# Base class for RIB modules.
#
# @example
#   class AwesomeRIBModule < RIB::Module::Base
#     
#     describe 'Hell, yeah!'
#
#     describe go_nuts: 'what a great bot command'
#
#     def go_nuts
#       'WOOOOOOOHOOOOOOOOOOoooOOOO'
#     end
#
#     trigger /\binsane\b/ do
#       "I'm not insane! oO Oo"
#     end
#
#   end

class RIB::Module::Base

  extend RIB::Helpers


  class << self

    ##
    # If the module can only be used with specific protocols, these
    # can be set in this attribute. If it works with all protocols,
    # it is nil.
    #
    # @return [Array<Symbol>] if it works with several protocols
    # @return [nil]           if it works with all protocols

    attr_reader :protocols


    ##
    # Callback method, which is called when a class inherits from this
    # class. Used to add the sublass to our loaded module list.
    
    def inherited(subclass)
      RIB::Module.loaded << subclass
      @init_blocks = []
      @descriptions = {}
      @timeouts = Hash.new(5)
      @triggers = {}
    end


    ##
    # @return [Symbol] base class name of this class

    def key
      name.split(':').last.to_sym
    end


    ##
    # @return [Array<Proc>] blocks that should be called on init

    def init_blocks
      @init_blocks ||= []
    end


    ##
    # @return [Array<Symbol>] all available commands for this module

    def commands
      public_instance_methods(false)
    end


    ##
    # @return [Hash{Symbol => String}] descriptions for module and
    #   commands

    def descriptions
      @descriptions ||= {}
    end


    ##
    # @return [Hash{Symbol => Fixnum}] timeouts for commands

    def timeouts
      @timeout ||= Hash.new(5)
    end


    ##
    # @return [Hash{Regexp => Proc}] triggers and the blocks that should
    #   be called when they match

    def triggers
      @triggers ||= {}
    end


    ##
    # Check if this module responds to the command name and if this
    # method can take the number of arguments
    #
    # @param command_name [Symbol] name of the command
    # @param args_count   [Fixnum] number of arguments
    #
    # @return [Boolean]

    def has_command_for_args?(command_name, args_count)
      unless public_instance_methods(false).include?(command_name)
        return false 
      end

      method = instance_method(command_name)
      params = method.parameters.group_by(&:first)

      return true if params[:rest]

      args_min = params[:req].to_a.count
      args_max = args_min + params[:opt].to_a.count

      args_count.between?(args_min, args_max)
    end


    ##
    # Call the {.init_blocks} for this module.
    #
    # @param bot [Bot] the Bot instance the modules are used for.
    #
    # @return [void]

    def init(bot)
      init_blocks.each do |block|
        block.call(bot)
      end
    end


    private

    ##
    # Register a {Configuration] directive for the module.
    #
    # @param hash [Hash{Symbol => Object}]
    #
    # @return [void]

    def register(hash)
      raise TypeError, 'not a Hash' unless hash.is_a? Hash

      hash.each do |config_key, default_value|
        if config_key.respond_to?(:to_sym)
          RIB::Configuration.register(config_key.to_sym, default_value)
        end
      end
    end


    ##
    # Define a block that is called when {.init} is called for the
    # module by a Bot.
    #
    # @yieldparam bot [Bot]

    def on_init(&block)
      init_blocks << block if init_blocks.none?(&:source_location)
    end


    ##
    # If a String is passed, sets the description for the RIB::Module.
    # If a Hash is passed, it sets descriptions for the commands with
    # the name of the keys.
    #
    # @see #descriptions
    #
    # @param argument [String, Hash{Symbol => #to_s}]
    #
    # @return [void]

    def describe(argument)
      case argument
      when String
        descriptions[nil] = argument
      when Hash
        argument.each do |cmd, desc|
          if cmd.respond_to?(:to_sym) && desc.respond_to?(:to_s)
            descriptions[cmd.to_sym] = desc.to_s 
          end
        end
      end
    end


    ##
    # Set timeout for a command or a trigger. Default timeout is 5
    # seconds.
    #
    # @param hash [Hash{Symbol => Fixnum}]
    #
    # @return [void]

    def timeout(hash)
      raise TypeError, 'not a Hash' unless hash.is_a? Hash

      hash.each do |command, timeout|
        raise TypeError, 'not a Fixnum' unless timeout.is_a?(Fixnum)
        timeouts[command] = timeout
      end
    end


    ##
    # Define a block a bot should call if a message matches the
    # trigger. The block is evaluated in the instance scope of the
    # bot module it belongs to, which shall inherit from
    # {RIB::Module::Base}.
    #
    # @example
    #   trigger /\bcrap\b/ do
    #     "#{msg.user}: oh yes, everything is crap!"
    #   end
    #
    # @param regexp [Regexp] when to be invoked
    #
    # @yield 
    # @yieldreturn [String, [String, String]]
    #
    # @raise [TypeError] if regexp is not a Regexp
    #
    # @return [Proc] the block

    def trigger(regexp, timeout = nil, &block)
      if regexp.is_a?(Regexp)
        triggers[regexp] = block
        timeouts[regexp] = timeout.to_i if timeout
      else
        raise TypeError, "not a Regexp: #{regexp.inspect}"
      end
    end

  end


  ##
  # The bot instance the module is called for.
  #
  # @return [Bot]

  attr_reader :bot
  
  
  ##
  # The message the module is called for.
  #
  # @return [Message]

  attr_reader :msg


  ##
  # @param bot [Bot]
  # @param msg [Message]

  def initialize(bot, msg)
    @bot, @msg = bot, msg
  end


  private

  ##
  # Logger that can be used for convenient logging from a module.
  #
  # @return [Logger]

  def logger
    unless @logger
      @logger = bot.logger.dup
      @logger.progname = self.class.name
    end
    @logger
  end

end
