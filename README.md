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

Con el SoC sintetizado en Litex, se procede a generar el código en software. Este código tiene inicialmente la iniciación de la máscara, del UART y del I2C, luego, se usa un while infinito para utilizar el registro del configuración y escribirle al acelerómetro su dirección (0x53) más un bit de lectura o escritura, a continuación, se le escribe al registro de crl del acelerómetro (0x2D). Por último se escribe un 0x8 para configurar la medida de aceleración.
