// FUNCTION
(Sys.init)
// Push Constant
@4000
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@5000
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@1
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// CALL
@Sys.init$RETURN_ADDRESS_0
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@5
D=A
@SP
D=M-D
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.main
0;JMP
(Sys.init$RETURN_ADDRESS_0)
// Pop Temp
@R5
D=A
@1
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
(Sys.init$LOOP)
@Sys.init$LOOP
0;JMP
// FUNCTION
(Sys.main)
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@4001
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@5001
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@1
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@200
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Local
@LCL
D=M
@1
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@40
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Local
@LCL
D=M
@2
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@6
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Local
@LCL
D=M
@3
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@123
D=A
@SP
A=M
M=D
@SP
M=M+1
// CALL
@Sys.main$RETURN_ADDRESS_1
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@6
D=A
@SP
D=M-D
@ARG
M=D
@SP
D=M
@LCL
M=D
@Sys.add12
0;JMP
(Sys.main$RETURN_ADDRESS_1)
// Pop Temp
@R5
D=A
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Local
@LCL
D=M
@0
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Local
@LCL
D=M
@1
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Local
@LCL
D=M
@2
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Local
@LCL
D=M
@3
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Local
@LCL
D=M
@4
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Return
@LCL
D=M
@R14
M=D
@5
D=A
@R14
D=M-D
A=D
D=M
@R15
M=D
@ARG
D=M
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
@1
D=A
@ARG
D=M+D
@SP
M=D
@1
D=A
@R14
D=M-D
A=D
D=M
@THAT
M=D
@2
D=A
@R14
D=M-D
A=D
D=M
@THIS
M=D
@3
D=A
@R14
D=M-D
A=D
D=M
@ARG
M=D
@4
D=A
@R14
D=M-D
A=D
D=M
@LCL
M=D
@R15
A=M
0;JMP
// FUNCTION
(Sys.add12)
// Push Constant
@4002
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Constant
@5002
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Pointer
@R3
D=A
@1
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
// Push Argument
@ARG
D=M
@0
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@12
D=A
@SP
A=M
M=D
@SP
M=M+1
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Return
@LCL
D=M
@R14
M=D
@5
D=A
@R14
D=M-D
A=D
D=M
@R15
M=D
@ARG
D=M
@0
D=A+D
@R13
M=D
@SP
M=M-1
A=M
D=M
@R13
A=M
M=D
@1
D=A
@ARG
D=M+D
@SP
M=D
@1
D=A
@R14
D=M-D
A=D
D=M
@THAT
M=D
@2
D=A
@R14
D=M-D
A=D
D=M
@THIS
M=D
@3
D=A
@R14
D=M-D
A=D
D=M
@ARG
M=D
@4
D=A
@R14
D=M-D
A=D
D=M
@LCL
M=D
@R15
A=M
0;JMP