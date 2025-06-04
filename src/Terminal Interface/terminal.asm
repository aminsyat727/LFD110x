# Introduction to RISC-V
# Terminal Interface, by Eduardo Corpeño 

###################################################
# Description
#
# This code asks the user's name in the console 
# and responds with a message using that name.
###################################################

# Data Section
.data           #assembler directive .data; to specify that the following code will be stored in data section of memory.
prompt:   .string   "Hey, what's your name?\n"  #.string specify that the data stored will be in string (similar to initializing data type)
response: .string   "\nIt's good to meet you, " 
name:     .string   "                       "

# Code Section
.text 

###################################################
# Main entry point.
# The program starts here, at address 0x00000000
###################################################

main:
    # Initializations
    la t0, name  # t0 points to the name string; la is a pseudocode to load address, in this case loading symbol "name" into address t0 

    # print_string(prompt) - Environment call 4 (ecall 4 is to print string)
    la a1, prompt   #load address; load "prompt" value into register a1
    li a0, 4        #oad immediate; load specified value (4 in this case) into a0
    ecall           #environment call; check the a0 value and do specific enviroment call depends on the value pass. 
                    #In this case the ecall will check the value of a0=4 which is to print the string in register a1.

    # Call read_str subroutine
    jal read_str    #jump and link; pass the execution into the specified subroutine (read_str subroutine in this case). 
                    #the next code in main runs back only after subroutine execution is done

    # print_string(response) - Environment call 4
    la a1, response #load address; load "response" value into register a1
    li a0, 4        #load immediate; specify the value 4 into register a0
    ecall           #environment call; check a0 value = 4, to print a1 string
    
    # print_string(name) - Environment call 4
    la a1, name     #load address; load "name" value into register a1
    li a0, 4        #load immediate; specify the value 4 into register a0
    ecall           #environment call; check a0 value = 4, to print a1 string
    
    # print_char(a0) - Environment call 11
    li a1, '!'      #load immediate; specify the value '!' into register a1
    li a0, 11       #load immediate; specify the value 11 into register a0
    ecall           #environment call; check a0 value = 11, to print a1 ASCII character
    
    li a1, '\n'     #load immediate; specify the value  '\n' into register a1
    ecall           #environment call; check a0 value = 11, to print a1 ASCII character
    ecall           #environment call; check a0 value = 11, to print a1 ASCII character
                    #by running ecall twice we wil have a single empty line in terminal. This is usually done to beutify the terminal output

    # Exit - Environment call 10
    li a0, 10       #load immediate; specify the value 20 into register a0
    ecall           #environment call; check a0 value = 10, to end program

###################################################
# read_str subroutine
# Read input string from the console.
# This input is a line of text terminated with
# the enter keystroke.
###################################################

read_str:
    # Initializations
    li a5, 1  # a5 holds comparison value for branching

    # Enable console input - Environment call 0x130
    li a0, 0x130    #load immediate; specify value 0x130 into register a0
    ecall           #environment call; check value a0 = 0x130, to ask terminal input

read_char:
    # Read a character from console input - Environment call 0x131
    li  a0, 0x131   #load immediate; specify value 0x131 into register a0
    ecall           #environment call; check value a0 = 0x130, to read terminal input

    # Read the result of the environment call in a0
    beq a0, a5, read_char   # If still waiting for input, keep polling 
                            #compare the value between a0 and a5; and do read_chr if compared value is same 
    beq a0, zero, finish    # If buffer is empty, go to finish
                            #compare the value between a0 and zero; and do finish if compared value is same 
    
    # Handle incoming character
    sb   a1, 0(t0)          # Append input character to name string
                            #store byte; a1 as the register destination, 0(t0) means to take the value from register t0 at index 0 
    addi t0, t0, 1          # Increment the name string pointer
                            #Add immediate; t0 as the destination and add t0 + 1; what happens here should be that it makes space for the next 0(t0) for the upcoming character

    # Iterate to get the next character
    j read_char             #jump to the read_char subroutine

finish:
    # Subroutine epilogue
    sb zero, 0(t0)  # Append null-terminator to name string
                    #store byte; store the null numerator into zero
    jr ra           # Return to caller
                    # jump register. go back to register a
