/* ###################################################################
**     Filename    : main.c
**     Project     : Perro
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2018-01-23, 22:33, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "TI1.h"
#include "AD1.h"
#include "AS1.h"
#include "Bit2.h"
#include "PWM1.h"
#include "Cap1.h"
#include "Bit1.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/*Inicializacion de la maquina de estados*/
unsigned char estado = ESPERAR;

//variables para el protocolo de comunicacion
unsigned int acelerometro;
unsigned int luz;

bool digitalUno;
bool digitalDos;
unsigned char error;
unsigned int bytesEnviados = 5;
unsigned char mensaje[7];
unsigned int time; 



#define TRUE  1
#define FALSE 0

/* User includes (#include below this line is not maintained by Processor Expert) */

void main(void)
{
  /* Write your local variable definition here */

  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
  for(;;) { 
  	  switch(estado){
  	  	  case ESPERAR:
  	  		  break;
  	  	  case MEDIR:
  	  
	  		  error = AD1_MeasureChan(1,0);
	  		  error = AD1_GetChanValue(0,&luz);
	  		  error = AD1_MeasureChan(1,1);
	  		  error = AD1_GetChanValue(1,&acelerometro);
  	  		  //digitalUno = Bit1_GetVal();
  	  		  digitalDos = Bit2_GetVal();
  	  		  estado = ENVIAR;
  	  		  break;
  	  	  case ENVIAR:
  	  		  /*FORMACION DE TRAMA*/
  	  		  mensaje[0] = 0xF0+NRO_CANALES;  //Byte que dice la cantidad de canales
  	  		  mensaje[1] = (acelerometro>>7) & 0x1F;
  	  		  mensaje[2] = (acelerometro) & 0x7F;
  	  		  
  	  		  mensaje[3] = (luz>> 7) & 0x1F;
  	  		  mensaje[4] = (luz) & 0x7F;
  	  		  mensaje[5] = (time>>7) & 0x7F;
  	  		  mensaje[6] = time & 0x7F;
  	  		  
  	  		  //Trama para los sensores digitales
  	  		 // if (digitalUno == FALSE){
  	  			  
  	  		 // }else
  	  		 //	  mensaje[1] = mensaje[1] & 0x3F;
  	  		  if (digitalDos == FALSE){
  	  			  mensaje[1] = mensaje[1] | 0x20; 
  	  		  }else
  	  			  mensaje[1] = mensaje[1] & 0x5F;
  	  		  
  	  		  
  	  		  //Envio de la trama
  	  		  error = AS1_SendBlock(mensaje,7,&bytesEnviados);
  	  		  /*WRAP TRAMA*/
  	  		  estado = ESPERAR;
  	  		  break;
  	  	  default:
  	  		  break;
  	  }
    }
  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
