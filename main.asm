; Project 1
; Author: Yueqiao Wang
; Date: 12/14/2023
; Description: 	This assembly program is designed for the MSP432P4111 microcontroller, utilizing the ARM Cortex-M4 architecture.
; 				The code controls the initialization and behavior of three LEDs (red, green, and blue) and two switches (SW1 and SW2).
;				The main functionality includes toggling the system state based on switch input, changing LED colors, and implementing software debouncing for switch input.
;				The program is intended for an embedded system application, providing basic LED control and switch interaction.
; Last-revised: 12/14/2023


	.thumb          		; 16-bit instruction set
	.global main			; export main symbol so it is recognized by other source files
	.text					; what follows goes in CODE region of memory map

;--------------------------------------------------------------
; redLedInit - Initializes Red LED
; Description: Initializes pin for LED2-Red
; Input: None
; Output: None
; Registers: R0, R1 (temporary storage)
;--------------------------------------------------------------
redLedInit
    PUSH    {R0, R1}		; Push R0 and R1 to stack to save them
    MOV     R0, #0			; Initialize R0 to 0
    ; Set function of pin P1.0 to GPIO
    LDR     R1, P2SEL0_0    ; Load address P2SEL0 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL0 to clear its bit 0
    LDR     R1, P2SEL1_0    ; Load address P2SEL1 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL1 to clear its bit 0
    ; Set direction of P1.0 to output
    LDR     R1, P2DIR_0     ; Load address P2DIR to R1
    ORR     R0, R0, #1      ; Set Bit 0 of R0 to be "1"
    STRB    R0, [R1]        ; Store R0 to P2DIR to set direction of P1.0 to output
    ; Set default output to 0 so initially off
    LDR     R1, P2OUT_0     ; Load address P2OUT to R1
    AND     R0, R0, #0      ; Set Bit 0 of R0 to be "1"
    STRB    R0, [R1]        ; Set it to 0 so initially off
    POP     {R0, R1}        ; Pop R0 and R1 from the stack to restore them
    BX      LR              ; Return to the caller


;--------------------------------------------------------------
; greenLedInit - Initializes Green LED
; Description: Initializes pin for LED2-Green
; Input: None
; Output: None
; Registers: R0, R1 (temporary storage)
;--------------------------------------------------------------
greenLedInit
    PUSH    {R0, R1}       ; Push R0 and R1 to stack to save them
    MOV     R0, #0          ; Set R0 to 0
    ; Set function of pin P2.1 to GPIO
    LDR     R1, P2SEL0_1    ; Load address P2SEL0 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL0 to clear its bit 0
    LDR     R1, P2SEL1_1    ; Load address P2SEL1 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL1 to clear its bit 0
    ; Set direction of P2.1 to output
    LDR     R1, P2DIR_1     ; Load address P2DIR to R1
    ORR     R0, R0, #1      ; Set Bit 0 of R0 to be "1"
    STRB    R0, [R1]        ; Store R0 to P2DIR to set direction of P2.1 to output
    ; Set default output to 0 so initially off
    LDR     R1, P2OUT_1     ; Load address P2OUT to R1
    AND     R0, R0, #0      ; Set Bit 0 of R0 to be "0"
    STRB    R0, [R1]        ; Set it to 0 so initially off
    POP     {R0, R1}        ; Pop R0 and R1 from the stack to restore them
    BX      LR              ; Return to the caller


;--------------------------------------------------------------
; blueLedInit - Initializes Blue LED
; Description: Initializes pin for LED2-Blue
; Input: None
; Output: None
; Registers: R0, R1 (temporary storage)
;--------------------------------------------------------------
blueLedInit
    PUSH    {R0, R1}       ; Push R0 and R1 to stack to save them
    MOV     R0, #0          ; Initialize R0 to 0
    ; Set function of pin P2.2 to GPIO
    LDR     R1, P2SEL0_2    ; Load address P2SEL0 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL0 to clear its bit 0
    LDR     R1, P2SEL1_2    ; Load address P2SEL1 to R1
    STRB    R0, [R1]        ; Store R0 to P2SEL1 to clear its bit 0
    ; Set direction of P2.2 to output
    LDR     R1, P2DIR_2     ; Load address P2DIR to R1
    ORR     R0, R0, #1      ; Set Bit 0 of R0 to be "1"
    STRB    R0, [R1]        ; Store R0 to P2DIR to set direction of P2.2 to output
    ; Set default output to 0 so initially off
    LDR     R1, P2OUT_2     ; Load address P2OUT to R1
    AND     R0, R0, #0      ; Set Bit 0 of R0 to be "0"
    STRB    R0, [R1]        ; Set it to 0 so initially off
    POP     {R0, R1}        ; Pop R0 and R1 from the stack to restore them
    BX      LR              ; Return to the caller


;--------------------------------------------------------------
; SW1init - Initializes Switch 1
; Description: Initializes configuration for switch connected to P1.4
; Input: None
; Output: None
; Registers: R0, R1 (temporary)
;--------------------------------------------------------------
SW1init
    PUSH    {R0, R1}          ; Push R0 and R1 to the stack to save them
    AND     R0, #0            ; Clear R0

    ; Set function of pin P1.1 to GPIO
    LDR     R1, P1SEL0_1      ; Load address P1SEL0 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL0 to clear its bit 1
    LDR     R1, P1SEL1_1      ; Load address P1SEL1 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL1 to clear its bit 1

    ; Set direction of P1.1 to input
    LDR     R1, P1DIR_1       ; Load address P1DIR to R1
    STRB    R0, [R1]          ; Store R0 to P1DIR to set direction of P1.1 to input

    ; Set internal resistor of P1.1 for pull-up
    ORR     R0, R0, #1     ; Set Bit 0 of R0 to be "1" (activate pull-up)
    LDR     R1, P1OUT_1       ; Load address P1OUT to R1
    STRB    R0, [R1]          ; Store R0 to P1OUT to activate pull-up

    ; Enable internal resistor of P1.1
    LDR     R1, P1REN_1       ; Load address P1REN to R1
    STRB    R0, [R1]          ; Store R0 to P1REN to enable internal resistor

    POP     {R0, R1}          ; Pop R0 and R1 from the stack to restore them
    BX      LR                ; Return to the caller

;--------------------------------------------------------------
; SW2init - Initializes Switch 2
; Description: Initializes configuration for switch connected to P1.4
; Input: None
; Output: None
; Registers: R0, R1 (temporary)
;--------------------------------------------------------------
SW2init
    PUSH    {R0, R1}          ; Push R0 and R1 to the stack to save them
    AND     R0, #0            ; Clear R0

    ; Set function of pin P1.4 to GPIO
    LDR     R1, P1SEL0_4      ; Load address P1SEL0_4 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL0_4 to clear its bit 4
    LDR     R1, P1SEL1_4      ; Load address P1SEL1_4 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL1_4 to clear its bit 4

    ; Set direction of P1.4 to input
    LDR     R1, P1DIR_4       ; Load address P1DIR_4 to R1
    STRB    R0, [R1]          ; Store R0 to P1DIR_4 to set the direction of P1.4 to input

    ; Set internal resistor of P1.4 for pull-up
    ORR     R0, R0, #1        ; Set Bit 4 of R0 to be "1" (activate pull-up)
    LDR     R1, P1OUT_4       ; Load address P1OUT_4 to R1
    STRB    R0, [R1]          ; Store R0 to P1OUT_4 to activate pull-up

    ; Enable internal resistor of P1.4
    LDR     R1, P1REN_4       ; Load address P1REN_4 to R1
    STRB    R0, [R1]          ; Store R0 to P1REN_4 to enable the internal resistor

    POP     {R0, R1}          ; Pop R0 and R1 from the stack to restore them
    BX      LR                ; Return to the caller

;--------------------------------------------------------------
; TESTSWinit - Initializes Test Switch
; Description: Initializes configuration for the test switch connected to P1.5
; Input: None
; Output: None
; Registers: R0, R1 (temporary)
;--------------------------------------------------------------
TESTSWinit
    PUSH    {R0, R1}          ; Push R0 and R1 to the stack to save them
    AND     R0, #0            ; Clear R0

    ; Set function of pin P1.5 to GPIO
    LDR     R1, P1SEL0_5      ; Load address P1SEL0_5 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL0_5 to clear its bit 5
    LDR     R1, P1SEL1_5      ; Load address P1SEL1_5 to R1
    STRB    R0, [R1]          ; Store R0 to P1SEL1_5 to clear its bit 5

    ; Set direction of P1.5 to input
    LDR     R1, P1DIR_5       ; Load address P1DIR_5 to R1
    STRB    R0, [R1]          ; Store R0 to P1DIR_5 to set the direction of P1.5 to input

    ; Set internal resistor of P1.5 for pull-up
    ORR     R0, R0, #1        ; Set Bit 5 of R0 to be "1" (activate pull-up)
    LDR     R1, P1OUT_5       ; Load address P1OUT_5 to R1
    STRB    R0, [R1]          ; Store R0 to P1OUT_5 to activate pull-up

    ; Enable internal resistor of P1.5
    LDR     R1, P1REN_5       ; Load address P1REN_5 to R1
    STRB    R0, [R1]          ; Store R0 to P1REN_5 to enable the internal resistor

    POP     {R0, R1}          ; Pop R0 and R1 from the stack to restore them
    BX      LR                ; Return to the caller


;--------------------------------------------------------------
; ToggleSystem
; Description: Toggles, run, and close the system
; Input: None
; Output: None
; Registers: R5, R6, R7, R4, R8, R9
;--------------------------------------------------------------

ToggleSystem
	PUSH {LR}            	; Save the return address on the stack
    EOR		R5, R5, #1      ; Toggle the least significant bit

	CMP 	R5, #1          ; Compare R5 with 1
	BEQ		systemON        ; Branch to systemON if equal

systemOFF					; else System should Off now
	AND		R6, R6, #0		; Clear R6
	AND 	R7, R6, #0		; Clear R7
	B		endToggleSystem	; Branch to end of this method

systemON
	ORR		R6, R6, #1		; Turn on the LED

systemONloop
	BL		EnableLED		; Call EnableLED function to update LED
	MOV     R4, #0x2654		; Load R4 with 0x0000_000A
    MOVT    R4, #0x1		; Load the high part of R4 with 0x0000_0007
counter_delay
    SUBS    R4, #1		; Decrement R4

	;if the SW1 is pressed, turn off the system
    LDRB    R0, [R8]		; Load the value of SW1 input
    TST     R0, #0x01		; Test if bit 0 is set (SW == 1)
    BEQ		systemOFF       ; Branch to systemOFF if SW1 is pressed

	; else check SW2
	; change color if SW2 is pressed
    LDRB    R0, [R9]		; Load the value of SW2 input
    TST     R0, #0x01		; Test if bit 0 is set (SW == 1)
    BNE		colorNotChangeSystemONloop  ; Branch to colorNotChangeSystemONloop if SW1 is not pressed

	BL		ChangeColor		; Call ChangeColor function
    BL		EnableLED       ; Call EnableLED function to update LED
    BL		SWDebounce      ; Call SWDebounce function

	; checked whether SW2 is still pressed
ifSW2releaseSystemONloop
    LDRB    R0, [R9]		; Load the value of switch input
    TST     R0, #0x01		; Test if bit 0 is set (SW == 1)
    BEQ     ifSW2releaseSystemONloop  ; Branch to ifSW2releaseSystemONloop if SW2 is still pressed

	; normal situation
colorNotChangeSystemONloop

	;check whether the delay is finished
	CMP 	R4, #0			; Compare R4 with 0
    BNE     counter_delay	; Branch to counter_delay if not finished

	EOR		R6, R6, #1		; Toggle the least significant bit in R6, change LED state
    B		systemONloop	; Branch to systemONloop

endToggleSystem

	BL		EnableLED		; Call EnableLED function to update

    POP {LR}				; Restore the return address from the stack
    BX LR					; Return from the function
;--------------------------------------------------------------


;--------------------------------------------------------------
; ChangeColor -	Increment Color through R7
; Description:	This function increments the value in register R7 by 1. If the
;				resulting value is equal to 3, R7 is set to 0.
; Input:		None
; Output:		R7
; Registers:	R7 - Used to store and manipulate the color value
;               LR - Link Register, used to save the return address during function call
;--------------------------------------------------------------
ChangeColor
    PUSH {LR}          ; Save the return address on the stack

    ADD R7, R7, #1     ; Increment the value in R7 by 1 and set flags

    CMP R7, #3          ; Compare R7 with 3
    BNE NoOverflow      ; Branch to NoOverflow if not equal (no overflow)
    MOV R7, #0          ; Set R7 to 0 if overflow

NoOverflow
    POP {LR}           ; Restore the return address from the stack
    BX LR               ; Return from the function


;--------------------------------------------------------------
; EnableLED - Enable or disable LEDs based on input parameters
;
; Description: Enables or disables LEDs based on the input values.
;
; Input:
;   R5:    State for System (0 - System Off, 1 - System On)
;   R6:    State for LED 2 (0 - disable, 1 - enable)
;   R7:    LED color (0 - disable, 1 - red, 2 - green, 3 - blue)
;
; Output: LEDs are enabled or disabled accordingly
;	R7:    LED color
;   R10:   State for Red LED
;   R11:   State for Green LED
;   R12:   State for blue LED
;
; Registers:
;   R0:    Temporary register
;   R5:    State for System
;   R6:    State for LED 2
;   R7:    LED color
;   R10:   State for Red LED
;   R11:   State for Green LED
;   R12:   State for blue LED
;   LR:    Link Register
;
;--------------------------------------------------------------

EnableLED
    PUSH {LR}         ; Save Link Register

    CMP R5, #0        ; Compare R5 with 0
    BEQ disable       ; Branch to disable if R5 is 0

    CMP R6, #0        ; Compare R6 with 0
    BEQ disable       ; Branch to disable if R6 is 0

    CMP R7, #0        ; Compare R7 with 0
    BEQ enableRed     ; Branch to enableRed if R7 is 0

    CMP R7, #1        ; Compare R7 with 1
    BEQ enableGreen   ; Branch to enableGreen if R7 is 1

    CMP R7, #2        ; Compare R7 with 2
    BEQ enableBlue    ; Branch to enableBlue if R7 is 2

    B endEnableLED    ; Branch to endEnableLED if R7 is not 0, 1, or 2

;--------------------------------------------------------------
; enableRed - Enable red LED
;--------------------------------------------------------------
enableRed
    AND R0, R0, #0    ; Clear R0
    STRB R0, [R11]    ; Store 0 in the memory pointed to by R11
    STRB R0, [R12]    ; Store 0 in the memory pointed to by R12

    ORR R0, R0, #1    ; Set the least significant bit in R0 to 1
    STRB R0, [R10]    ; Store 1 in the memory pointed to by R10
    B endEnableLED    ; Branch to endEnableLED

;--------------------------------------------------------------
; enableGreen - Enable green LED
;--------------------------------------------------------------
enableGreen
    AND R0, R0, #0    ; Clear R0
    STRB R0, [R10]    ; Store 0 in the memory pointed to by R10
    STRB R0, [R12]    ; Store 0 in the memory pointed to by R12

    ORR R0, R0, #1    ; Set the least significant bit in R0 to 1
    STRB R0, [R11]    ; Store 1 in the memory pointed to by R11
    B endEnableLED    ; Branch to endEnableLED

;--------------------------------------------------------------
; enableBlue - Enable blue LED
;--------------------------------------------------------------
enableBlue
    AND R0, R0, #0    ; Clear R0
    STRB R0, [R10]    ; Store 0 in the memory pointed to by R10
    STRB R0, [R11]    ; Store 0 in the memory pointed to by R11

    ORR R0, R0, #1    ; Set the least significant bit in R0 to 1
    STRB R0, [R12]    ; Store 1 in the memory pointed to by R12
    B endEnableLED    ; Branch to endEnableLED

;--------------------------------------------------------------
; disable - Disable all LEDs
;--------------------------------------------------------------
disable
    AND R0, R0, #0    ; Clear R0
    STRB R0, [R10]    ; Store 0 in the memory pointed to by R10
    STRB R0, [R11]    ; Store 0 in the memory pointed to by R11
    STRB R0, [R12]    ; Store 0 in the memory pointed to by R12
    B endEnableLED    ; Branch to endEnableLED

;--------------------------------------------------------------
; endEnableLED - Clean up and return
;--------------------------------------------------------------
endEnableLED
    POP {LR}          ; Restore the return address from the stack
    BX LR             ; Return from the function

;--------------------------------------------------------------
; SWDebounce - Software Debouncing Routine
;
; Description:
;   This subroutine implements a simple software debouncing mechanism using a
;   delay loop. It decrements R0 from SWDebounce_DELAY_COUNT to 0 in a loop, providing a delay
;   for debouncing switch input.
;
; Input:
;   None
;
; Output:
;   None
;
; Registers:
;   R0 - Loop counter
;
;--------------------------------------------------------------
SWDebounce
        ; Initialize R0 with the debounce delay value
        LDR     R0, SWDebounce_DELAY_COUNT

debounce_delay
        ; Decrement R0 by 1
        SUBS    R0, #0x01

        ; Check if R0 is not zero, loop if not equal
        BNE     debounce_delay

        ; Return from subroutine
        BX      LR


;--------------------------------------------------------------
; Function: Main Function
; Description: Main function for handling switch input and LED toggling
; Input: None
; Output: None
; Registers: R4-R12 (Global storage), R0 (temporary storage)
;--------------------------------------------------------------
main
    AND     R4, #0          ; Clear R4 - 500ms Counter
    AND     R5, #0          ; Clear R5 - System State
    AND     R6, #0          ; Clear R6 - LED State
    AND     R7, #0          ; Clear R7 - Color
    AND     R8, #0          ; Clear R8 - address of switch 1
    AND     R9, #0          ; Clear R9 - address of switch 2
    AND     R10, #0         ; Clear R10 - address of red LED
    AND     R11, #0         ; Clear R11 - address of green LED
    AND     R12, #0         ; Clear R12 - address of blue LED
    LDR     R8, SW1         ; Load address of switch 1
    LDR     R9, SW2         ; Load address of switch 2
    LDR     R10, REDLED     ; Load address of red LED
    LDR     R11, GREENLED   ; Load address of green LED
    LDR     R12, BLUELED    ; Load address of blue LED


    BL      redLedInit      ; Initialize red LED
    BL      greenLedInit    ; Initialize green LED
    BL      blueLedInit     ; Initialize blue LED
    BL      SW1init         ; Initialize switch 1
    BL      SW2init         ; Initialize switch 2

    ;Test Code
    ;BL		TESTSWinit		; Initialize TEST SWITCH
    ;LDR    R9, TESTSW      ; Load address of TEST SWITCH

; Check whether SW1 is pressed
; If pressed, debounce for 5ms and check next
loop
    LDRB    R0, [R8]        ; Load value of switch 1 input
    TST     R0, #0x01       ; Test if bit 0 is set (SW == 1)
    BNE     loop            ; Keep checking if not pressed (SW == 0)

    ; Button is pressed, debounce 5ms
    BL      SWDebounce

; Check whether the switch is released
; If released, debounce for 5ms and toggle system state
release
    LDRB    R0, [R8]        ; Load value of switch 1 input
    TST     R0, #0x01       ; Test if bit 0 is set (SW == 1)
    BEQ     release         ; Keep checking while pressed (SW == 0)

    ; Button is released, debounce 5ms
    BL      SWDebounce
    BL      ToggleSystem    ; Toggle system state

; System is off, wait for next start
    B       loop


    .align 4
;--------------------------------------------------------------
; Peripheral Registers
;--------------------------------------------------------------
; Red LED (P2.0)
P2SEL0_0    .word  0x42098160   ; P2SEL0 bit_word_addr for P2.0
P2SEL1_0    .word  0x420981A0   ; P2SEL1 bit_word_addr for P2.0
P2DIR_0     .word  0x420980A0   ; P2DIR bit_word_addr for P2.0
P2OUT_0     .word  0x42098060   ; P2OUT bit_word_addr for P2.0
REDLED		.word  0x42098060   ; Memory-mapped address for REDLED OUTPUT

; Green LED (P2.1)
P2SEL0_1    .word  0x42098164   ; P2SEL0 bit_word_addr for P2.1
P2SEL1_1    .word  0x420981A4   ; P2SEL1 bit_word_addr for P2.1
P2DIR_1     .word  0x420980A4   ; P2DIR bit_word_addr for P2.1
P2OUT_1     .word  0x42098064   ; P2OUT bit_word_addr for P2.1
GREENLED	.word  0x42098064   ; Memory-mapped address for GREENLED OUTPUT

; Blue LED (P2.2)
P2SEL0_2    .word  0x42098168   ; P2SEL0 bit_word_addr for P2.2
P2SEL1_2    .word  0x420981A8   ; P2SEL1 bit_word_addr for P2.2
P2DIR_2     .word  0x420980A8   ; P2DIR bit_word_addr for P2.2
P2OUT_2     .word  0x42098068   ; P2OUT bit_word_addr for P2.2
BLUELED		.word  0x42098068   ; Memory-mapped address for BLUELED OUTPUT

; Switch 1 (P1.1)
P1SEL0_1	.word  0x42098144   ; P1SEL0 bit_word_addr for P1.1
P1SEL1_1	.word  0x42098184   ; P1SEL1 bit_word_addr for P1.1
P1DIR_1		.word  0x42098084   ; P1DIR bit_word_addr for P1.1
P1REN_1     .word  0x420980C4   ; P1REN bit_word_addr for P1.1
P1OUT_1		.word  0x42098044   ; P1OUT bit_word_addr for P1.1
P1IN_1		.word  0x42098004   ; P1IN bit_word_addr for P1.1
SW1			.word  0x42098004   ; Memory-mapped address for SW1 Input

; Switch 2 (P1.4)
P1SEL0_4	.word  0x42098150   ; P1SEL0 bit_word_addr for P1.4
P1SEL1_4	.word  0x42098190   ; P1SEL1 bit_word_addr for P1.4
P1DIR_4		.word  0x42098090   ; P1DIR bit_word_addr for P1.4
P1REN_4     .word  0x420980D0   ; P1REN bit_word_addr for P1.4
P1OUT_4		.word  0x42098050   ; P1OUT bit_word_addr for P1.4
P1IN_4		.word  0x42098010   ; P1IN bit_word_addr for P1.4
SW2			.word  0x42098010   ; Memory-mapped address for SW2 Input

; TEST Switch
P1SEL0_5    .word  0x42098154	; P1SEL0 bit_word_addr for P1.5
P1SEL1_5    .word  0x42098194	; P1SEL1 bit_word_addr for P1.4
P1DIR_5     .word  0x42098094	; P1DIR bit_word_addr for P1.5
P1REN_5     .word  0x420980D4	; P1REN bit_word_addr for P1.5
P1OUT_5     .word  0x42098054	; P1OUT bit_word_addr for P1.5
P1IN_5      .word  0x42098014	; P1IN bit_word_addr for P1.5
TESTSW		.word  0x42098014   ; Memory-mapped address for TEST SW Input

SWDebounce_DELAY_COUNT     .word     0x1388 ; method count that leads 5ms delay


.end
