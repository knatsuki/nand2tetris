// Push Constant
@111
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@333
D=A
@SP
A=M
M=D
@SP
M=M+1
// Push Constant
@888
D=A
@SP
A=M
M=D
@SP
M=M+1
// Pop Static
@SP
M=M-1
A=M
D=M
@StaticTest.8
M=D
// Pop Static
@SP
M=M-1
A=M
D=M
@StaticTest.3
M=D
// Pop Static
@SP
M=M-1
A=M
D=M
@StaticTest.1
M=D
// Push Static
@StaticTest.3
D=M
@SP
A=M
M=D
@SP
M=M+1
// Push Static
@StaticTest.1
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
// Push Static
@StaticTest.8
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
