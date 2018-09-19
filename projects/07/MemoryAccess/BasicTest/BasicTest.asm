// Push Constant
@10
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
// Push Constant
@21
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@22
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Argument
@ARG
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
// Pop Argument
@ARG
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
@36
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop This
@THIS
D=M
@6
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
@42
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@45
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop That
@THAT
D=M
@5
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
// Pop That
@THAT
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
@510
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Temp
@R5
D=A
@6
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
// Push That
@THAT
D=M
@5
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
// Push This
@THIS
D=M
@6
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push This
@THIS
D=M
@6
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
// Subtract
@SP
M=M-1
A=M
D=M
A=A-1
M=M-D
// Push Temp
@R5
D=A
@6
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
