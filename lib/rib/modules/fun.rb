# coding: utf-8

RIB::Module.new :fun do
  desc 'Couple of useless commands'

  command :moar do
    desc 'Gimme MOAR!'
    on_call do |what|
      "MOAR #{what}! MOAAR!!!1 "
    end
  end


  command :blame do
    desc 'What the hell is wrong with her/him?'
    on_call do |who|
      "dafuq #{who} oO"
    end
  end


  response :yognaught, /\A((ACTION|\/me)\s+salutes()?)\Z/ do
    desc 'Yes, I am!'
    on_call do
      match[1] + '\nI am Dave ! Yognaught and I have the balls!'
    end
  end

end
