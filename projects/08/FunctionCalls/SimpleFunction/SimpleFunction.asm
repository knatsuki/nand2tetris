(SimpleFunction.test)
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
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Not
@SP
A=M-1
M=!M
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
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Push Argument
@ARG
D=M
@1
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Subtract
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
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
@R14
A=M
0;JMP