// Push Constant
@3030
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
@3040
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
@32
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop This
@THIS
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
@46
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop That
@THAT
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
// Push Pointer
@R3
D=A
@0
A=A+D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Pointer
@R3
D=A
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
// Push This
@THIS
D=M
@2
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
// Push That
@THAT
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
