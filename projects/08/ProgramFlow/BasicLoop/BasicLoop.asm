// Push Constant
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Local
@LCL
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
($LOOP_START)
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
// Add
@SP
M=M-1
A=M
D=M
A=A-1
M=M+D
// Pop Local
@LCL
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
@1
D=A
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
// Pop Argument
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
@SP
M=M-1
A=M
D=M
@$LOOP_START
D;JNE
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
