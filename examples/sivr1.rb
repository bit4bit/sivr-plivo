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


class PedirEdad < SIVRPlivo
  set_url_ivr('http://localhost:3000')

  answer do
    pre_answer{
      speak('hi pre answer', :loop => 3)
    }
    speak('hi how are you, give me a number')
    get_digits{|digits|
      speak('you give me the number')
      speak(digits)
    }
  end

  answer_hangup do
    print "Cuelge\n"
  end
  
end



