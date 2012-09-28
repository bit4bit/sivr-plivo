SIVR-PLIVO
====

Creacion de IVRs para Plivo de forma sencilla como escribir aplicativos en Ruby.

Write IVRs for Plivo like Ruby Programs.


Requerimientos
====
* Ruby 1.9

Librerias
----
* GRAPE > 0.2

Doc
====
El aplicativo utiliza los Fibers de Ruby y la libreria Grape para realizar las etapas continuadas entre las multiples llamadas desde los servicios Plivo.


Ejemplos/Example
====
```ruby
class SuperIVR < SIVRPlivo #SubClass Grape::API
  def answer do
    #Escriba la logica de su IVR
    play '/audio/presentacion.wav'
    get_digits(:audio => '/audio/decir_un_numero.wav') do |digits|
      puts "Usted indico el numero %d" % digits.to_i
    end
  end

  def hangup do
    puts "Hasta despues"
  end
end
```
