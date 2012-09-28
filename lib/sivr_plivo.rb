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

#IVR Facilmente programable para Plivo
#::author:: Bit4bit <bit4bit@riseup.net>
#::date:: 2012-09-27


require 'grape'
require 'fiber'
require 'securerandom'



#Esta clase simula un IVR con plivo de forma continuada utilizando los fibers de ruby 1.9
#permientiendo escribir IVR con el lenguaje ruby, ej:
# class PedirEdad < SIVR
#  answer do
#   get_digits(:audio => '/audios/pediredad.wav'){|edad|
#     print "Su edad es %s" % edad
#   }
#  end
# end
#
#

class SIVRPlivo < Grape::API
  @@url_ivr = 'http://localhost:3000' #url donde se inicio el SIVR
  @@xml_doctype = '<?xml version="1.0" encoding="UTF-8" ?>'
  @@fibers_ivr = {} #se almacena fibers para postergar ejecucion

  def self.set_url_ivr(url)
    @@url_ivr = url
  end
  

  #Responde llamada
  #::prefix:: se pueden crear varios subivrs indicando un prefijo
  #::&block:: bloque que se ejecuta cuando plivo inicia llamada
  def self.answer(prefix = '', &block)
    desc "Process digits sends by plivo"
    post(prefix + '/digits/:id') do
      content_type 'text/xml'
      id = params[:id]
      ivrxml = ''
      if not @@fibers_ivr[id].nil?
        ivrxml += SIVRPlivo._fibers_to_ivrxml(@@fibers_ivr[id], params['Digits'])
        @@fibers_ivr.delete(id) #se elimina
      end
      SIVRPlivo._response(ivrxml)
    end
    
    desc "Process answer send by plivo"
    post(prefix + '/answer') do
      content_type 'text/xml'
      ivrxml = ''
      ivrxml = SIVRPlivo._fibers_to_ivrxml(Fiber.new(&block))
      SIVRPlivo._response(ivrxml)
    end
  end
  
  
  #Se ejecuta bloque cuando se cuelga la llamada
  def self.answer_hangup(&block)
    desc "Hangup the plivo call"
    get('/hangup', &block)
    post('/hangup', &block)
  end
  
  #Plivo::GetDigits
  #
  #Espera para obtener digitos de plivo
  #y notifica al fiber correspondiente
  #Tener presente que se esta en un Fiber, no se debe utilizar **return** hay que usar **next**.
  def self.get_digits(args = {}, &block)
    uuid = SecureRandom.uuid 
    @@fibers_ivr[uuid] = Fiber.new(&block)
    return Fiber.yield '<GetDigits action="%s/digits/%s" %s  method="POST" />' % [@@url_ivr, uuid, args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')]
  end

  
  #Plivo::Play
  #Reproducir audio
  def self.play(resource, args={})
    return Fiber.yield '<Play %s >%s</Play>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), resource]
  end
  
  #Plivo::Speak
  #Pronuciar texto
  def self.speak(txt, args={})
    return Fiber.yield '<Speak %s >%s</Speak>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), txt]
  end

  #Plivo::Record
  def self.record(args={})
    return Fiber.yield '<Record %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
  end

  #Plivo::Hangup
  def self.hangup(args={})
    return Fiber.yield '<Hangup %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
  end

  #PLivo::Redirect
  def self.redirect(url, args={})
    return Fiber.yield '<Redirect %s>%s</Redirect>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), url]
  end
  
  #Plivo::SIPTransfer
  def self.sip_transfer(uri, args={})
    return Fiber.yield '<SIPTransfer %s>%s</SIPTransfer>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), uri]
  end

  #Plivo::Wait
  def self.wait(args={})
    return Fiber.yield '<Wait %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
  end

  #Plivo::GetSpeech
  def self.get_speech(args={}, &block)
    ivrxml = SIVRPlivo._fibers_to_ivrxml(Fiber.new(&block), args)
    return Fiber.yield '<GetSpeech %s/>%s</GetSpeech>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), ivrxml ]
  end
  
  #Plivo::PreAnswer
  def self.pre_answer(args={}, &block)
    ivrxml = SIVRPlivo._fibers_to_ivrxml(Fiber.new(&block), args)
    return Fiber.yield '<PreAnswer>%s</PreAnswer>' % ivrxml
  end
  
  #Plivo::Dial
  def self.dial(args={}, &block)
    ivrxml = SIVRPlivo._fibers_to_ivrxml(Fiber.new(&block), args)
    return Fiber.yield '<Dial %s/>%s</Dial>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), ivrxml ]
  end

  #Plivo::Dial:Number
  #**Attention** debe ser usado dentro de Plivo::Dial
  def self.number(number, args={})
    return Fiber.yield '<Number %s/>%s</Number>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), number ]
  end
  
  #Plivo::Conference
  def self.conference(name, args={})
    return Fiber.yield '<Conference %s/>%s</Conference>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), name ]
  end
  
  
  private
  
  def self._response(msg)
    return '%s<Response>%s</Response>' % [@@xml_doctype, msg]
  end

  #Ejecuta fibers para continuar la logica del ivr y ademas para obtener xml del ivr
  #para plivo
  def self._fibers_to_ivrxml(fiber, *args)
    ivrxml = '';
    while fiber.alive?
      ivrxml += fiber.resume(*args).to_s
      ivrxml.gsub!(/[^>]+$/, '') #limpia basura de la ultima llamada
    end
    return ivrxml
  end
end
