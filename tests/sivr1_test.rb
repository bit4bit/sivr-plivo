# Copyright (C) 2012 Bit4Bit <bit4bit@riseup.net>
#
#
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
$:.unshift '../lib'
$:.unshift '../examples'

require 'rack/test'
require 'sivr_plivo'
require 'sivr1'
require 'minitest/autorun'

require 'securerandom'

class PedirEdadTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    PedirEdad
  end

  def test_single_answer
    post "/answer"
    assert last_response.body.include?('action='), 'not found: action'
    assert last_response.body.include?('hi pre answer'), 'not found: hi pre answer'
    
    action = last_response.body.scan(/action=\"([^\"]+)\"/).first.first.strip
    id = action.scan(/[^\/]+$/).first
    send_digits = SecureRandom.random_number(3000)
    post "/digits/%s" % id, {:Digits => send_digits}
    assert last_response.status == 201, 'bad response'
    assert last_response.body.include?('<Speak  >%d</Speak>' % send_digits), 'Not get the digit send'
  end

  #Testing multiples answer, this like a strees
  #we need to know how much memory use with Fibers
  def test_thread_answer
    threads = []
    (1..10).each{
      threads << Thread.new{
        post "/answer"
        assert last_response.status == 201
        assert last_response.body.include?('action='), 'not found: action'
        assert last_response.body.include?('hi pre answer'), 'not found: hi pre answer'
        
        action = last_response.body.scan(/action=\"([^\"]+)\"/).first.first
        id = action.scan(/[^\/]+$/).first
        send_digits = SecureRandom.random_number(3000)
        post "/digits/%s" % id, {:Digits => send_digits}
        assert last_response.status == 201, 'bad response'
        assert last_response.body.include?('<Speak  >%d</Speak>' % send_digits), 'Not get the digit send %s' % send_digits
      }
    }
    threads.each{|t| t.join}
    threads.clear()
  end

  #Hay incovenientes con los Threads y los Fibers
  #https://github.com/eventmachine/eventmachine/blob/dd675e4d061785cfe8240cd98e4c7525cd6fdae5/docs/old/LIGHTWEIGHT_CONCURRENCY
  #Entonces el programa debe ser corrido con un servicio como thin o que usen eventmachine
  #ya que este corre en un solo thread, o bien eso fue lo que no encontre en el codigo de
  #eventmachine.
  def test_answer_fibers
    threads = []
    ids = []
    mutex = Mutex.new
    (1..10).each{
      threads << Thread.new{
        post "/answer"
        assert last_response.body.include?('action='), 'not found: action'
        assert last_response.body.include?('hi pre answer'), 'not found: hi pre answer'
        
        action = last_response.body.scan(/action=\"([^\"]+)\"/).first.first.strip
        id = action.scan(/[^\/]+$/).first
        mutex.synchronize{
          ids << id
        }
      }
    }
    threads.each{|t| t.join}
    threads.clear()

    threads = []
    ids.each{|uid|
      threads << Thread.new(uid){|id|
        send_digits = SecureRandom.random_number(3000)
        post "/digits/%s" % id, {:Digits => send_digits}
        assert last_response.status == 201, 'bad response'
        assert last_response.body.include?('<Speak  >%d</Speak>' % send_digits), 'Not get the digit send'
      }
    }
    threads.each{|t| t.join}
    threads.clear()
  end
  
  def test_hangup
    post "/hangup"
  end
  
  
  
end

