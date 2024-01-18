class ELTEX < Oxidized::Model
  prompt /^\s?[\w.@\(\)-]+[#>]\s?$/
  comment '! '

  cmd :all do |cfg|
    cfg.cut_both
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

  cmd 'show version' do |cfg|
    cfg.gsub! /^(\s{0,10}*System uptime) .+/, '\\1 <configuration removed>'
    comment cfg.each_line.reject { |line| line.match /^  (Copyright |All rights reserved$|Uptime is |Last reboot is )/ }.join
  end

    cmd 'show running-config' do |cfg|
    cfg
  end

  cfg :telnet do
    username /^(User Name):/
    password /^Password:/
  end

  cfg :telnet, :ssh do
    # preferred way to handle additional passwords
    post_login do
      if vars(:enable) == true
        cmd "enable"
      elsif vars(:enable)
        cmd "enable", /^[pP]assword:/
        cmd vars(:enable)
      end
    end
    post_login 'terminal datadump'
    # disable cli pagination for MES2424
    #post_login 'set cli pagination off'
    pre_logout 'disable'
    pre_logout 'exit'
  end
end
