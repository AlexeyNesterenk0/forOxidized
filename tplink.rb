
class TPlink < Oxidized::Model
  prompt /[\>|\#]/
  comment '! '

  expect /[^>#\r\n]$/ do |data, re|
    send "\r"
    data.sub re, ''
  end

  expect /Press\s?any\s?key\s?to\s?continue\s?\(Q\s?to\s?quit\)/ do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    # remove unwanted paging line
    cfg.gsub! /^Press any key to contin.*/, ''
    # normalize linefeeds
    cfg.gsub! /(\r|\r\n|\n\r)/, "\n"
    # remove empty lines
    cfg.each_line.reject { |line| line.match /^[\r\n\s\u0000#]+$/ }.join
  end

  cmd :secret do |cfg|
    cfg.gsub! /^(\s{0,10}*System uptime ) .+/, '\\1 <configuration removed>'
    cfg.gsub! /^(snmp-server community(?: r[ow])?(?: \d)?) .+/, '\\1 <secret hidden>'
    cfg.gsub! /^(snmp-server user .+ auth \S+) .+/, '\\1 <secret hidden>'
    cfg.gsub! /^(enable secret) .+/, '\\1 <secret hidden>'
    cfg.gsub! /^(username .+ password \d) .+/, '\\1 <secret hidden>'
    cfg.gsub! /^(enable password(?: level \d+)? \d) .+/, '\\1 <secret hidden>'
    cfg.gsub! /^((webmaster level d{0,10}\s)?username \w{0,20} \w{0,20}*\s?\d{0,20}*\s?) .+/, '\\1 <configuration removed>'
    cfg
  end

  cmd 'show system-info' do |cfg|
    #cfg.gsub! /(System Time\s+-).*/, '\\1 <stripped>'
    #cfg.gsub! /(Running Time\s+-).*/, '\\1 <stripped>'
    comment cfg
  end

  cmd 'terminal length 0'
  
  cmd 'show running-config' do |cfg|
    #lines = cfg.each_line.to_a[1..-1]
    # cut config after "end"
    #lines[0..lines.index("end\n")].join
    cfg
  end

  cfg :telnet do
    username /^(User Name):/
    password /^Password:/
  end

  cfg :telnet, :ssh do
    post_login "enable"
    post_login "terminal length 0"
    pre_logout do
      send "exit\r"
      send "logout\r"
    end
  end
end
