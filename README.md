# SoC I2C acelerómetro

## Integrantes del equipo de trabajo:

### 1 Camilo Cristian Fernando Camargo Patarroyo cfcamargop@unal.edu.co

### 2 Maria Fernanda Triviño Cristancho mftrivinoc@unal.edu.co


## Descripción general del SoC: 

El presente proyecto consiste en un sistem on chip que tiene integrado un procesador LM32 con un timer, 
UART, leds, I2C, implementado en Litex. Este sistema fue programado para que recibiera las direcciones 
de un acelerómetro ADXL345, y las imprimiera en el terminal. A su vez muestra en los leds el registro de estatus.

## Descripción del acelerómetro ADXL345: 

En la siguiente imagen se muestra el módulo del acelerómetro.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/ADXL345.jpg)

En el datasheet de este módulo (adjunto en la documentación), se encontrará el mapa de memoria, en el cual se especifica que para que el módulo mida la aceleración se debe modificar el registro 0x2D (POWER_CTL) con un 00001000 (número en binario). Posteriormente, se leen el registro 0x32 en al cual están los primeros 8 bits de la posición x, se procede a lerr 0x33 donde están los 8 bits restantes. 

## Descripción del SoC:

En la siguiente imagen se muestra el SoC.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/mapa.png)

Este SoC está compuesto por un procesador LM32, un wishbone, un módulo led, un I2C, UART y timer. Los módulos timer, UART y leds están implemetados en Litex, mientras que I2C está implementado en Verilog. 

Por último se presenta el mapa general de memoria en la siguiente imagen

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/mapa_gen.png)

### I2C Verilog

En la carpeta i2c_verilog se encontrarán los módulos de I2C, los cuales fueron descargados de OpenCore. Fue necesario modificar el wishbone, con el fin de pasarlo de Verilog a Litex. Como también, se cambió el registro de status, ya que TIP no funcionaba de la manera deseado, por lo que se utilizó como transfering proccess el registro cnt_done, el cual indica cuando la tranferencia ha terminado. 

Se decidió cambiar los reset a software, dado que se presentador varios problemas como fallos con TIP, no realizaba el cálculo de cambio de frecuencia y problemas de valores iniciales con algunos registros.

Al final, luego de anexar el múdulo a Litex, se generó el siguiente mapa de memoria.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/i2c.png)

### LEDS 

El módulo leds consiste en un pinout implementado en el SoC.py, al cual desde software se le envía cómo debe prender y apagar por medio del Wishbone. Se debe aclarar que se usó una Nexys 4 (tener en cuanta a la hora de usar el código), por lo cual se pudieron usar 9 leds.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/leds.png)

### Timer, UART y control

Estos módulos fueron anexados de los repositorios de Litex, a continuación se muestran los mapas de memoria correspondientes.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/timer.png)
![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/uart.png)
![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/crl.png)

## Firmware

Con el SoC sintetizando en Litex, se procede a generar el código en software. Este código tiene inicialmente una función para inicializar I2C, la cual resetea el módulo y le pone el tiempo de funcionamiento (frecuencia de 1kHz). En el main se pone primero la iniciación de la máscara, del UART y del I2C, luego, se usa un while infinito para utilizar el registro del configuración y escribirle al acelerómetro su dirección (0x53) más un bit de lectura o escritura, a continuación, se le escribe al registro de crl del acelerómetro (0x2D). Por último se escribe un 0x8 para configurar la medida de aceleración.

Para probar que esto funcionara, se realizó un blinker usando el módulo de leds. Esto consistía en enviar un 0x0 y un 0xff para que prendieran y apagaran los leds, esto con un tiempo de espera de 3 segundos (para esto se usa el timer).

### I2C.c

Se generó un nuevo código que contiene las funciones del I2C, este consta de una función de escriyura y una función de enviado. 

La función de escritura consiste en recibir dos datos, los cuales le envía a la función send con su respectivo comando de escritura, lectura y parada (el número de dichos comandos se encuentra en I2C.h), una vez termina de enviar los dos datos se sale de la función.

Por otro lado, la función send empezaba con actualizar el dato que recibió de escritura. Luego, manda el dato que recibió de la misma función para activar el ciclo de enviado. Luego entra en un while que mantiene esperando al SoC hasta que el bit 2 del registro de status (TIP) se vuelva 0. Sin embargo, esta función presentó problemas, ya que el while usaba un and que inicialmente se puso en lógica (&&), pero se corrigió por comparación bit a bit (&). Posteriormente espera un ACK, el cual hace que la función de escritura vuelva a enviar el dato en caso de ACK ser igual a 1, de lo contrario continuar el proceso.

## I2C

Es un protocolo de comuniación de dos cables (SDA y SCL), el cual tiene la ventaja de conectar un master con varios slave. Para esto es necesario conectar dos resistencia de pull-up y tener en cuenta que entre más dispositivos se conecten aumenta la capacitancia y puede dejar de funcionar.

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/i2cc.jpg)

El protocolo consiste en:
* **Bit de start** El bit de start consiste en bajar sda de alto a bajo mientras scl esté en alto.
* **Adress+W/R**

![](https://github.com/Fernanda-Trivino/SoC/blob/master/SoC_I2C/ima/II2c.png)
