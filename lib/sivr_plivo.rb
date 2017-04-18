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
require 'active_support/concern'
require 'fiber'
require 'securerandom'

module SIVR
  class Plivo
    
    #Plivo::GetDigits
    #Espera para obtener digitos de plivo
    def get_digits(args = {}, &block)
      return Fiber.yield '<GetDigits %s method="POST" />' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')]
    end
    
    #Plivo::Play
    #Reproducir audio
    def play(resource, args={})
      return Fiber.yield '<Play %s>%s</Play>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), resource]
    end
    
    #Plivo::Speak
    #Pronuciar texto
    def speak(txt, args={})
      return Fiber.yield '<Speak %s>%s</Speak>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), txt]
    end

    #Plivo::Record
    def record(args={})
      return Fiber.yield '<Record %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
    end

    #Plivo::Hangup
    def hangup(args={})
      return Fiber.yield '<Hangup %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
    end

    #PLivo::Redirect
    def redirect(url, args={})
      return Fiber.yield '<Redirect %s>%s</Redirect>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), url]
    end
    
    #Plivo::SIPTransfer
    def sip_transfer(uri, args={})
      return Fiber.yield '<SIPTransfer %s>%s</SIPTransfer>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), uri]
    end

    #Plivo::Wait
    def wait(args={})
      return Fiber.yield '<Wait %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
    end

    #Plivo::GetSpeech
    def get_speech(args={}, &block)
      ivrxml = build(Fiber.new(&block), args)
      return Fiber.yield '<GetSpeech %s/>%s</GetSpeech>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), ivrxml ]
    end
    
    #Plivo::PreAnswer
    def pre_answer(args={}, &block)
      ivrxml = build(Fiber.new(&block), args)
      return Fiber.yield '<PreAnswer>%s</PreAnswer>' % ivrxml
    end
    
    #Plivo::Dial
    def dial(args={}, &block)
      ivrxml = build(Fiber.new(&block), args)
      return Fiber.yield '<Dial %s>%s</Dial>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), ivrxml ]
    end

    #Plivo::Dial:Number
    #**Attention** debe ser usado dentro de Plivo::Dial
    def number(number, args={})
      raise ArgumentError, 'number: Gateways *mandatory' unless args.keys.map{|i| i.to_s.upcase}.include?('GATEWAYS')

      return Fiber.yield '<Number %s>%s</Number>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), number ]
    end
    
    #Plivo::Conference
    def conference(name, args={})
      return Fiber.yield '<Conference %s>%s</Conference>' % [args.map{|k,v| "#{k}=\"#{v}\""}.join(' '), name ]
    end

    
    #Plivo::Hangup
    def hangup(args={})
      return Fiber.yield '<Hangup %s/>' % args.map{|k,v| "#{k}=\"#{v}\""}.join(' ')
    end

    #Ejecuta fibers para continuar la logica del ivr y ademas para obtener xml del ivr
    #para plivo
    def build(fiber, *args)
      ivrxml = '';
      while fiber.alive?
        ivrxml += fiber.resume(*args).to_s
        ivrxml.gsub!(/[^>]+$/, '') #limpia basura de la ultima llamada
      end
      return ivrxml
    end

    def xml_response(xml)
      return '<?xml version="1.0" encoding="UTF-8" ?><Response>%s</Response>' % [xml]
    end

    def self.run(*args, &block)
      instance = SIVR::Plivo.new
      msg = instance.build(Fiber.new(&proc{
                                       instance.instance_eval(&block)
                                     }), *args)
      instance.xml_response(msg)
    end
    
  end

  module Helpers
    extend ActiveSupport::Concern

    included do
      helpers do
        def plivo(&block)
          SIVR::Plivo.run(&block)
        end
      end
    end

  end
end

#Esta clase simula un IVR con plivo de forma continuada utilizando los fibers de ruby 1.9
#permientiendo escribir IVR con el lenguaje ruby, ej:
# class PedirEdad < SIVR
#  answer do
#   wait length: 10
#  end
# end
#
#

class SIVRPlivo < Grape::API
  #Responde llamada
  #::prefix:: se pueden crear varios subivrs indicando un prefijo
  #::&block:: bloque que se ejecuta cuando plivo inicia llamada
  def self.answer(prefix = '', &block)
    desc "Process answer send by plivo"
    post(prefix + '/answer') do
      content_type 'text/xml'
      SIVR::Plivo.run(&block)
    end
    get(prefix + '/answer') do
      content_type 'text/xml'
      SIVR::Plivo.run(&block)
    end
  end
  
  #Se ejecuta bloque cuando se cuelga la llamada
  def self.answer_hangup(&block)
    desc "Hangup the plivo call"
    get('/hangup', &block)
    post('/hangup', &block)
  end
end
