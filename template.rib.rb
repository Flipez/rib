module RIB
  module MyModules
    class Moduletemplate
      TRIGGER = /regexp/
      #HELP = "helpful text"
      
      # s = source of message, m = matchdata of TRIGGER-regexp
      def output( s, m )
        out = m[1]
        return nil, out
      end

    end
  end
end
