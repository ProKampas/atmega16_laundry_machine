.include "m16def.inc"


.def temp_input=R17
.def password=R18
.def input = R19
.def proplisi=R20
.def inner_count_L=R24
.def inner_count_H=R25
.def outer_count_L=R26
.def outer_count_H=R27

.cseg 

.org 0x0000

Reset:
	ldi R16,low(RAMEND)
	out SPL,R16
	ldi R16,high(RAMEND)
	out SPH,R16
	clr password
	clr proplisi
	clr temp_input
	clr input
	out DDRD,input	;PORTD as input
	com input
	out DDRB,input	;PORTB as output
	clr input
	ldi R16,0X7F
	out PORTB,R16	;LED7 will be on as long as 230V is supplied
	rjmp Insert_code
	

	;Insert code with an 8 sec delay. The user has 8 seconds to put the code in the washing machine.
	;The code will be completed and processed after 8 seconds, not earlier.
Insert_code:
	ldi outer_count_L,0b11001001	;Outer count is 10.000
	ldi outer_count_H,0b00000001
	outer_loop:
		ldi inner_count_L,0b00010000	;Inner count is 457 
		ldi inner_count_H,0b00100111
	inner_loop:
		in input,PIND
		com input
		or password,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop
		rjmp Check_code

	;���� �� �������� ��� ����� �� ��������� ��� ������ �� ������� ��� ������ ������ ��� �������� 
	;�� ��������� ������� ���� ������� ����� � �������.�� � ������� ��� ����� ����� ����� ����
	;�� ��������� �� ����� Reset.
	;��������� �� �� ����� ������� �� ��������� SW0,SW1,SW2,SW6,SW7..
Check_code:
	clt
	bst password,0
	brts Reset
	bst password,1
	brts Reset
	bst password,2
	brts Reset
	bst password,6
	brts Reset
	bst password,7
	brts Reset
	
	;�� � ������� ����� �� ����� ������ � ������� �� ����������� �� �� ����� ���� ��� LED ���
	;1 ������������.
	call Delay_finish


	; ������, ���� 8 ������������ ���� ��� �� ������� ��� ����� ��������
	;��� ��������� ��� � ���.��� �����, ������ ����� �� ������� ��� SW2.�� ������� ������������
	;���� �������� ����� �� �������� ��� �� ��������� �� ���������� ����� ��������.
	
	rjmp Check_proplisi

	
	;������� ���������.�� 8 ������������ ������ �� ������� �� SW2
Check_proplisi:	
	ldi outer_count_L,0b11001001	;Outer count is 10.000
	ldi outer_count_H,0b00000001
	outer_loop2:
		ldi inner_count_L,0b00010000	;Inner count is 457 
		ldi inner_count_H,0b00100111
	inner_loop2:
		in input,PIND
		com input
		or proplisi,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop2
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop2
	
	;���� �������� � �������� �� ��������� ��� ��������� �� �� ������ ���� ��� LED
	;������� ���� ��� ����.
	call Delay_finish
	rjmp Check_payload

	
	;���� �� �������� ����� ���� ������ ��� ����� �������������.���� �� 8 ������������ � �������
	;������ �� ������� �� ������� SW1 ��� �� ������ ��� �� ��������� �������������.
	;�� ���, ��������� �������� �� ���������� ���.����� ��������� � ������ �����
	;������� ��� �� LED ��� ��� ������������ �������� ��� Delay_finsh ��� � �������
	;��������� ��������.��� ���� ������� � SW1 ���� ����������� �� LED1 �� ������� 1s.
Check_payload:
	call Delay_8sec
			
	;������� ��� SW1.A� �������� �������� � ������� Overloaded
	bst temp_input,1
	brts Overloaded
  Continue_payload:	
	;�� ��������� ��������� ��� ������ ��� � ����� ����� �������.
	call Delay_finish
	jmp Check_door





	;����� ������� �� ���� � SW1 ���� ����������� ��� ���� ��� ������ ������
	;���� �� ��������� ��� �� ����� �������������.
Overloaded:
	ldi R16,0b01111101  ;������� �� LED1 KAI LED7
	out PORTB,R16
	call Delay_1sec
	;�� ������� �� SW1  �� ��������� ���������� ���� ��� ���� ������.
	sbrc temp_input,1
	rjmp Continue_payload	
	;������� ��� LED ��� �������� ����� ����� ���� �� LED7.
	ldi R16,0b01111111
	out PORTB,R16
	call Delay_1sec	
	;�� ������� �� SW1  �� ��������� ���������� ���� ��� ���� ������.
	sbrc temp_input,1
	rjmp Continue_payload
	rjmp Overloaded
	
	


	;�� ��������� ��������� �� ������ 8 ������������ �� ������� ���
	;���� ��� ����� ������� � �������.��� ��� ����� ����� �������� 
	;���� � ����� ������� ��� ������ �� LED0 ��� ��� ��������� ��� � ����� �������.
	;�������� ����� �� LED7.
Check_door:
	call Delay_8sec
	bst temp_input,0
	brts Door_open
	ldi R16,0b01111110	;����� ����� �������.
	out PORTB,R16
	rjmp Wait_SW6

	;������ ��� ���� ������� � SW0 � ����� ����� ������� ��� ������ �� LED0
	;����� � ����� �� ����������.
	

Door_open:
	ldi R16,0b01111110
	out PORTB,R16
	call Delay_1sec
	bst temp_input,0
	brts Wait_SW6

	ldi R16,0b01111111
	out PORTB,R16
	call Delay_1sec
	bst temp_input,0
	brts Wait_SW6
	rjmp Door_open

	;����� ������� �� SW6 �������� � �������� ���������� ��� ����������.
	;��� ������� � ����� �� ��� ����������� � �������� �� ���� �� ���������
	;��������� ��� ����� �������� Reset. 

	;����� ������� � SW6 ������ �������� ��� ��������� ����������� ��� ������� ���
	;�� LED ��� ��� ������������.
Wait_SW6:
	ldi R16,0b01111110
	out PORTB,R16
	in input,PIND
	com input
	cpi input,64
	breq Proplisi_function
	rjmp Wait_SW6


	;�� ��������� �����: ��������,����� �����,��������,����������
	;��������: �� ������� 4sec
	;��������: 1sec ��� LED4
	;����������: 2sec ��� LED5
Proplisi_function:
	bst proplisi,2
	brts Delay_4sec_LED2
	rjmp Normal_function



Delay_4sec_LED2:
	ldi R16,0b01111010
	out PORTB,R16
	clr temp_input
	ldi outer_count_L,0b11001001	;Outer count is 10.000
	ldi outer_count_H,0b00000001
	outer_loop6:
		ldi inner_count_L,0b11100100	;Inner count is 228
		ldi inner_count_H,0b00000000
	inner_loop6:
		in input,PIND
		com input
		or temp_input,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop6
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop6
		ldi R16,0b01111110
		out PORTB,R16




	;���� �������� ���������� ����� ������ �� ������ ���� ��������� ������� 
	;� ������� ��� �� �������� ��������.
Normal_function:
	cpi password,0
	breq FunctionJmp_8sec
	cpi password,8
	breq FunctionJmp_16sec
	cpi password,16
	breq FunctionJmp_32sec
	cpi password,24
	breq FunctionJmp_64sec
	cpi password,32
	breq FunctionJmp_8sec
	cpi password,40
	breq FunctionJmp_16sec
	cpi password,48
	breq FunctionJmp_32sec
	cpi password,56
	breq FunctionJmp_64sec
	
FunctionJmp_8sec:
	jmp Function_8sec
FunctionJmp_16sec:
	jmp Function_16sec
FunctionJmp_32sec:
	jmp Function_32sec
FunctionJmp_64sec:
	jmp Function_64sec

	;������ �� LED3 ���� ����� ����� ��� ������ �� LED0 LED7 ����� ��������.
Function_8sec:
	ldi R16,0b01110110
	out PORTB,R16
	;����������� 8 �������������.���� �� ������� ��� ����������� ��� ��� 
	;������ ����� ������ �����(������ �����,������� ������).
	;��� ��� ��� ����������� ��������������� � ����� ���=(10Ni+1)(No-1)+10Ni+1
	clr temp_input
	ldi outer_count_L,0b00111111	;Outer count is 319
	ldi outer_count_H,0b00000001	
	outer_loop8:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop8:
		in input,PIND
		com input
		cpi input,1
		breq DoorJmp_open
		cpi input,128
		breq Water_supply_fail
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop8
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop8
	ldi R16,0b01111110
	out PORTB,R16
	call Xebgalma
	bst password,5
	brts StraggismaJmp
	jmp Reset1

StraggismaJmp:
	jmp Straggisma
DoorJmp_open: 
	jmp Door_open


	;��� �������� � ������ ����� ����(�� ������� � SW7) ���� ������ �� LED6 ���
	;����������� �� LED1
Water_supply_fail:
	ldi R16,0b00111100
	out PORTB,R16
	call Delay_1sec
	cpi temp_input,128
	breq Reset1
	ldi R16,0b00111110
	out PORTB,R16
	call Delay_1sec
	cpi temp_input,128
	breq Reset1
	rjmp Water_supply_fail

Reset1:
	jmp Reset

Function_16sec:
	ldi R16,0b01110110
	out PORTB,R16
	;����������� 16 �������������.���� �� ������� ��� ����������� ��� ��� 
	;������ ����� ������ �����(������ �����,������� ������).
	;��� ��� ��� ����������� ��������������� � ����� ���=(10Ni+1)(No-1)+10Ni+1
	clr temp_input
	ldi outer_count_L,0b01111111	;Outer count is 639
	ldi outer_count_H,0b00000010	
	outer_loop16:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop16:
		in input,PIND
		com input
		cpi input,1
		breq DoorJmp_open
		cpi input,128
		breq Water_supply_fail
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop16
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop16
	ldi R16,0b01111110
	out PORTB,R16
	call Xebgalma
	bst password,5
	brts StraggismaJmp
	jmp Reset1



Function_32sec:
	ldi R16,0b01110110
	out PORTB,R16
	;����������� 32 �������������.���� �� ������� ��� ����������� ��� ��� 
	;������ ����� ������ �����(������ �����,������� ������).
	;��� ��� ��� ����������� ��������������� � ����� ���=(10Ni+1)(No-1)+10Ni+1
	clr temp_input
	ldi outer_count_L,0b00000000	;Outer count is 1280
	ldi outer_count_H,0b00000101	
	outer_loop32:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop32:
		in input,PIND
		com input
		cpi input,1
		breq DoorJmp_open
		cpi input,128
		breq Water_supply_fail
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop32
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop32
	ldi R16,0b01111110
	out PORTB,R16
	call Xebgalma
	bst password,5
	brts Straggisma
	jmp Reset1



Function_64sec:
	ldi R16,0b01110110
	out PORTB,R16
	;����������� 32 �������������.���� �� ������� ��� ����������� ��� ��� 
	;������ ����� ������ �����(������ �����,������� ������).
	;��� ��� ��� ����������� ��������������� � ����� ���=(10Ni+1)(No-1)+10Ni+1
	clr temp_input
	ldi outer_count_L,0b00000000	;Outer count is 2560
	ldi outer_count_H,0b00001010	
	outer_loop64:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop64:
		in input,PIND
		com input
		cpi input,1
		breq DoorJmp1_open
		cpi input,128
		breq Water_supplyJmp_fail
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop64
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop64
	ldi R16,0b01111110
	out PORTB,R16
	call Xebgalma
	bst password,5
	brts Straggisma
	jmp Reset1

DoorJmp1_open: 
	jmp Door_open

Water_supplyJmp_fail:
	jmp Water_supply_fail
	;��� �������� ��� 1 ������������ �� LED4 ����� ��������.
Xebgalma:
	ldi R16,0b01101110
	out PORTB,R16
	call Delay_1sec
	ldi R16,0b01111110
	out PORTB,R16
	call Delay_1sec
	ret


	;�� ���������� ������� 2 ������������,��� ���� �� ��������� ���������.�� ��� ������ �� ����������� 
	;�� ������� ����� ���� �� �������� ��� ����������,��� � ������ ����� ��� �� ������� ��� ������.
	;� ����� ����� ���=(10Ni+1)(No-1)+10Ni+1
Straggisma:
	clr temp_input
	ldi outer_count_L,0b01010000	;Outer count is 80
	ldi outer_count_H,0b00000000
	outer_loop7:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop7:
		in input,PIND
		com input
		cpi input,1
		breq DoorJmp1_open
		cpi input,128
		breq Water_supplyJmp_fail
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop7
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop4
	jmp Reset1


Delay_8sec:
	clr temp_input
	ldi outer_count_L,0b11001001	;Outer count is 457
	ldi outer_count_H,0b00000001
	outer_loop4:
		ldi inner_count_L,0b00010000	;Inner count is 10000 
		ldi inner_count_H,0b00100111
	inner_loop4:
		in input,PIND
		com input
		or temp_input,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop4
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop4
	ret



Delay_1sec:
	clr temp_input
	;����������� ���� ������������� ��� � ������� ����� ������.
	;� ����� ��� ��������������� �����:  N�� = (7�i+5)(No-1)+7Ni+4 
	ldi outer_count_L,0b00111001	;Outer count is 57
	ldi outer_count_H,0b00000000
	outer_loop5:
		ldi inner_count_L,0b00010000	;Inner count is 10000
		ldi inner_count_H,0b00100111
	inner_loop5:
		in input,PIND
		com input
		or temp_input,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop5
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop5
	ret	




Delay_finish:
	clr R16
	out PORTB,R16	;All LEDs ON
	clr temp_input
	;����������� ���� ������������� ��� � ������� ����� ������.
	;� ����� ��� ��������������� �����:  N�� = (7�i+5)(No-1)+7Ni+4 
	ldi outer_count_L,0b00111001	;Outer count is 57
	ldi outer_count_H,0b00000000
	outer_loop1:
		ldi inner_count_L,0b00010000	;Inner count is 10000
		ldi inner_count_H,0b00100111
	inner_loop1:
		in input,PIND
		com input
		or temp_input,input
		sbiw inner_count_H:inner_count_L,1
		brne inner_loop1
		sbiw outer_count_H:outer_count_L,1
		brne outer_loop1
		
		;������� ��� LED ��� �������� ����� ����� ���� �� LED7.
		ldi R16,0x7F
		out PORTB,R16
		ret




