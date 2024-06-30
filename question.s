            AREA question, CODE, READONLY
            ENTRY
            
iterations  EQU 11                 ;an EQU statement called iterations to keep track of the amount of iterations to get to the length of the UPC string - 1 to prevent iterating over the check digit
    
            ADR R0, UPC            ;to access the elements of the UPC, load it into a register
            MOV R1, #0             ;a register is needed to track the sum of elements at odd indices 
            MOV R2, #0             ;a register is also needed to track the sum of elements at even indices
            MOV R3, #0             ;a loop counter to compare with the iterations label in the loop, so the compiler knows whether to exit or not

MainLoop    LDRB R4, [R0, R3]      ;each loop will load the next byte of the UPC string, sequentially as its respective ASCII value
            SUB R4, R4, #'0'       ;to get the sum, the ASCII value must be translated to its corresponding integer equivalent which can be done by subtraction
            TST R3, #1             ;by comparing two values with a bitwise AND, odd number's least significant bit is 1 and even number's LSB is 0. ANDing and odd to an odd yields 1 and ANDing an even to an odd yields 0.
            ADDNE R1, R1, R4       ;depending on the previous comparison determines which sum to add the current number to. Since it is not equal, the odd index element sum is updated
            ADDEQ R2, R2, R4       ;in contrast, if the result of the previous comparison is equal the even index element sum is updated
            ADD R3, R3, #1         ;the loop counter must be incremented to keep track of iterations in the UPC code
            CMP R3, #iterations    ;to know when to exit the loop, the current loop counter is compared to the number of iterations to ensure the compiler does not try to go out of bounds or stops before the entire UPC code has been iterated through
            BNE MainLoop           ;to ensure all digits of the UPC code are iterated through (other than the check digit), the code loops until it reaches the last digit of the UPC

            ;Logical Part for computing the check digit

            ADD R2, R2, R2, LSL #1 ;a LSL can be implemented to multiply the even index sum by 3
            ADD R1, R1, R2         ;we want the sum of all of the UPC code digits excluding the check digit so each sum must be added together
            LDRB R5,[R0,#11]       ;the check digit must be added to the new sum, so using indirect indexing to load the last element of the code into a register is needed to then add it later
            SUB R5, R5, #'0'       ;the ASCII value must be converted an integer for proper summation of the check digit and the new sum
            ADD R1,R5              ;the addition of the check digit with the new sum is for checking if the UPC is valid (multiple of 10) which is verified in the code following this line

DivRepeat   SUBS R1, R1, #10       ;using repeated subtractions in a loop is used to get the number down to 0. If the loop breaks at 0, the UPC is valid since it's a multiple of 10. If the loop breaks at a number other than 0, the UPC is not a multiple of 10 and hence invalid
            BGT DivRepeat          ;the loop must repeat while R1 - (R1-10) > 0 since we want zero as our final value to exit the loop
            MOVEQ R0,#1            ;the UPC is valid if it exits on zero, so the "EQ" condition verifies it is zero
            MOVNE R0,#2            ;the UPC is invalid if it exits on a number other than zero, so the "NE" condition verifies that it is invalid

Loop        B Loop                 ;Loop B Loop is needed to terminate the program
            
            ;Tester UPCs

UPC         DCB "013800150738"     ;tester UPC codes for the program 
UPC2        DCB "060383755577"     ;correct UPC
UPC3        DCB "160383755577"     ;incorrect UPC
            END
