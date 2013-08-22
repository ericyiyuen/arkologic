#! /usr/bin/env ruby
=begin
  * Name: HA.com Temporary Licence email request
  * Description: Send an email with two host ids and expect an reply email with licence files attached   
  * Author: Eric Yuan <ericy@arkologic.com>
  * Date: 06/26/2013
  * License: arkologic
=end
require 'net/smtp'
@from = 'Arkologic Tester <arkotester@gmail.com>'
@to = 'arkolic@high-availability.com'
@user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:17.0) Gecko/17.0 Thunderbird/17.0'
@message_id = '<51CAB9CC.9070209@arkologic.com>'
@subject = 'Temporary Licence Request'

def usage
  $stderr.puts("Usage: #{File.basename($0)} hostid1 hostid2")
  exit(2)
end

usage if ARGV.size < 2
#parsing parameters
@nodea = ARGV[0] if not ARGV[0].nil? 
@nodeb = ARGV[1] if not ARGV[1].nil? 
@message = <<MESSAGE_END
Message-ID: #{ @message_id }
From: #{ @from }
User-Agent: #{ @user_agent }
MIME-Version: 1.0
To: #{ @to }
Subject: #{ @subject }
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Nodea: #{ @nodea }
Nodeb: #{ @nodeb }
Type: temporary
Custref: Requested by Arkologic

MESSAGE_END

Net::SMTP.start('localhost') do |smtp|
  puts 'sent' if smtp.send_message @message, @from, @to
end
