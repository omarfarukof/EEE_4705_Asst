# Testing Process

* [X] Test LCD
* [X] Test LCD + Keypad
* [X] Test M_7SEG
* [X] Test LCD + Keypad + M_7SEG
* [X] Test Oven.ASM

# Assignment requirments

* [X] **Frequency:** $11+(22-12)*(ID/10^9)= 11+(200021118/10^8)=11+2.00021118 = 13.00021118 \,\,MHz$
* [X] Timer Input with Keypad
* [X] LCD showing time before Oven Counter Starts
* [X] Start Button to Start the Oven/Counter
  * [X] Seperate Button
  * [X] Using a Button in Keypad (`ON/C`)
* [X] Use LED to show the **Running Condition of Oven** *(On/OFF)*
* [X] Show the Countering of Counter in 7 Segment Display
* [X] **Condition on Time:**
  * [X] if Timer < 60s   	-> Show MSG_1 in LCD
  * [X] if Timer > 60s		-> In Every 20s show Different MSG_2[...]
* [X] When Timer/Counter/Oven Ends
  * [X] Show End MSG
  * [X] turn ON Buzzer
  * [X] Loop over to start
  * [X] Use (`ON/C`) on Keypad to Stop the Buzzer and Start Over
* [X] Emergency Button to Pause the Oven
  * [X] Emergency Button
  * [X] Show Emergency MSG in LCD with ***Remaining Time***

# Circuit Diagram

![Proteus Circuit Diagram](./proteus/OVEN_FINAL(v8.17).SVG)
