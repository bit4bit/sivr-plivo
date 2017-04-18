SIVR-PLIVO
====

Creacion de IVRs para Plivo de forma sencilla como escribir aplicativos en Ruby.

Write IVRs for Plivo like Ruby Programs.


Requerimientos
====
* Ruby 1.9
* gem *minitest*

Librerias
----
* GRAPE > 0.2

Doc
====
El aplicativo utiliza los Fibers de Ruby y la libreria Grape para realizar las etapas continuadas entre las multiples llamadas desde los servicios Plivo.

Se han mapeado todos los elementos de la siguiente forma:
**options:** los atributos de los elementos.


             * Speak => speak(txt, options={})
             * Play => play(url, options={})
             * GetDigits => get_digits(options={}, &block)
             * GetSpeech => get_speech(options={}, &block)
             * Record => record(options={})
             * Dial => dial(options={}, &block)
             *  Number => number(num, options={})
             * Conference => conference(options={})
             * Hangup => hangup(options={})
             * Redirect => redirect(url, options={})
             * SIPTransfer => sip_transfer(uri, options={})
             * Wait => wait(options={})
             * PreAnswer => pre_answer(options={}, &block)
             

Correr con:
	* *Thin* 
	
	
Ejemplos/Example
====

```ruby
class SuperIVR < SIVRPlivo #SubClass Grape::API
  post '/step/1' do
    hangup
  end
  
  def answer do
    pre_answer {
      speak 'bienvenido y bienvenida'
    }

    #Escriba la logica de su IVR
    play '/audio/presentacion.wav'
    get_digits(:action => 'http://localhost:3000/step1', :audio => '/audio/decir_un_numero.wav')

  end

  def answer_hangup do
    puts "Hasta despues"
  end
end
```

or include in Grape App

```ruby
class Demo < Grape::API
 include SIVR::Helpers
 
 get '/answer' do
   plivo do
     pre_answer { speak 'saludos' }
   end
 end
end
```
