# encoding: utf-8

#$LOAD_PATH.unshift File.expand_path('../mock', __FILE__)

require 'minitest/autorun'
require 'minitest/pride'
require 'rib/bot'

#old_verbose = $VERBOSE
#$VERBOSE = nil
#$VERBOSE = old_verbose


class TestBot < MiniTest::Test

  def setup
    @bot = RIB::Bot.new do |bot|
      bot.protocol  = :irc
      bot.server    = 'irc.example.org'
      bot.port      = 6667
      bot.channel   = '#test'
      bot.modules   = [:Core, :Fact]
      bot.logdir    = '/tmp/log'
    end
    @bot.instance_variable_set(:@logger, Logger.new('/dev/null'))
  end


  def test_construct
    assert_instance_of(RIB::Configuration, @bot.config)
    assert_equal(RIB::ModuleSet.new([]), @bot.modules)
    assert RIB::Module.loaded.any?
    assert RIB::Module.loaded.all? { |m| m.superclass == RIB::Module }
  end

  
  def test_get_connection_adapter
    ca = @bot.send(:get_connection_adapter)
    assert_equal RIB::Adapters::IRC, ca
  end


  def test_log_path
    assert_equal '/tmp/log/', @bot.send(:log_path)
  end


  def test_log_file_path
    assert_equal '/tmp/log/rake_test_loader.rb_irc_irc.example.org.log',
      @bot.send(:log_file_path)
  end


  def test_reload_modules
    assert_empty @bot.modules
    @bot.reload_modules
    assert @bot.modules.all? { |m| m.superclass == RIB::Module }
  end


  def test_init_server
    conn = MiniTest::Mock.new
    irc_conn = MiniTest::Mock.new
    conn.expect(:connection, irc_conn) 
    irc_conn.expect(:togglelogging, nil)
    irc_conn.expect(:login, nil)
    irc_conn.expect(:join_channel, nil, ['#test'])
    RIB::Adapters::IRC.stub(:new, conn) { @bot.send(:init_server) }
  end

end

