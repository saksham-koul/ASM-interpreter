# ASM-Interpreter

## Abstract
* Assembly language interpreter is a program that executes assembly - like instructions, read from a file or standard input, and displays the output on the screen.
* This project is an attempt to design an ASM (Assembly Language) interpreter for an Instruction set similar to Intel x86 architecture using primarily C language and programming tools like _**Flex**_ and _**Bison**_.
* It is a cross - platform program that can run on any computer having _**Flex**_ and _**Bison**_ installed in it.

## About Assembly Language
* Assembly language (often abbreviated ‘_**asm**_’) is a type of low-level programming language that is intended to communicate directly with a computer’s hardware.
* Unlike machine language which consists of binary and hexadecimal characters, assembly languages are designed to be human-readable.
* Because assembly depends on the machine code instructions, every assembly language is designed for exactly one specific computer architecture (or processor).
* Assembly Language is the interface between higher level languages (C++, Java, etc) and machine code (binary).
* Coding a program directly into assembly language will save the time of translation from high-level languages and is also more memory-efficient. However, it is much more difficult to write code in asm as compared to high-level languages and is
hence not a preferred option.
* A typical assembly language instruction looks like this -
![ASM instruction format](https://user-images.githubusercontent.com/78582744/130321917-3f6ad122-305c-4a3b-9cc9-d3487224025d.png)


## About Flex & Bison tools
Flex and Bison are tools for building programs that handle structured input. They were originally tools for building compilers, but they have proven to be useful in many other areas.

### Flex
* **FLEX (Fast Lexical analyzer generator)** is a tool/computer program for generating scanners/lexers - programs which recognize lexical patterns in text.
* Flex's actions are specified by definitions (which may include embedded C code) in one or more input files. The primary output file is _**lex.yy.c**_, which defines a routine _**yylex()**_.
* This file is compiled to produce an executable, which analyzes its input for occurrences of certain regular expressions and executes the corresponding C code on finding one.
    * For e.g., in statement ` a = b + c `

      Flex converts each individual character into tokens and recognizes `a`, `=`, `b`, `+`, `c`  as five different tokens .

#### Program structure of a lex file/code –
A lex file/code has the following general structure –

```
%{
// Definitions
%}
%%
Rules
%%
User code section
```

1. **Definition Section:** The definition section contains the declaration of variables, regular definitions, manifest constants. In the definition section, text is enclosed in `%{ %}` brackets. Anything written in
these brackets is copied directly to the file _**lex.yy.c**_.
2. **Rules Section:** The rules section contains a series of rules in the form: pattern action and pattern must be unintended and action begins on the same line in `{}` brackets. The rule section is enclosed in
`%% %%`.
3. **User Code Section:** This section contains C statements and additional functions. We can also compile these functions separately and load with the lexical analyzer.


### Bison
* **Bison** is a general-purpose parser generator that converts a grammar description (Bison Grammar Files) into a C program to parse that grammar.
* Flex is often used with Bison to tokenize input data and provide Bison with tokens.
    * For e.g., in statement ` a = b + c `
      
      Flex sends `a`, `=`, `b`, `+`, `c` as tokens and it is the job of Bison to make sure that the tokens are in the correct order i.e they follow the rules of language.

* The Bison parser is actually a C function named _**yyparse()**_, which is a function that reads tokens, executes actions, and ultimately returns as follows - 
    * Returns `0` if parsing was successful (return is due to end-of-input).
    * Returns `1` if parsing failed (return is due to a syntax error).


#### Program structure of a Bison file/code –
A Bison file/code has the following general structure –

```
%{
C Declarations
%}
Bison Declarations
%%
Grammar Rules
%%
Additional C code
```

## The ASM Interpreter
* This ASM interpreter for Intel x86 - like architecture in C language using Flex and Bison for lexical analysis and parsing respectively.
* The interpreter supports 26 registers (`a - z`).
* The registers can only hold integer data from range `-216 to 216`.
* The interpreter supports creation of labels in the assembly code. The rule for naming of labels is :
    * First letter should be an alphabet and the rest of the letters can be digits or alphabets.
    * Label name should not match with any instruction or register name.
* The interpreter is caseless i.e. the input data is case insensitive.
* Only one command per line is allowed.
* Literal numbers can be specified in Decimal (e.g `25`) , in Hexadecimal suffixed with `h` (e.g `ffh` means `255`) or in Binary suffixed with `b` (e.g `111b` means `7`).
* Interpreter also supports single line comments in the input file .
    * E.g. `add a,b ; put your comment here`

### Instruction set 
Following are the assembly instructions that the program can execute: 

* `ADD X, Y / num` - adds value of `Y` or `num` to the value stored in register `X`.
* `SUB X, Y / num` - subtracts value of `Y` or `num` from the value stored in register `X`.
* `MUL X, Y / num` - multiplies value of `Y` or `num` to the value stored in register `X`.
* `DIV X, Y / num` - divides the value stored in register `X` by `num` or value of `Y`.
* `MOV X, Y / num` - moves/copies the value of register `Y` or `num` into register `X`.
* `CMP X, Y / num` - modifies Z - flag by comparing the values stored in registers `X` and `Y`.
    * If `X` is equal to `Y` then the Z - flag is assigned `true`, otherwise `false`.
* `JMP LABEL` - **Unconditional Jump** - jumps to the label named LABEL.
* `JE LABEL` - **Conditional Jump** - jumps to LABEL if Z - flag is `true`.
* `JNE LABEL` - **Conditional Jump** - jumps to LABEL if Z - flag is `false`.
* `CALL LABEL` - jumps to the instructions written in the label named LABEL but also adds the address of next instruction into the stack top.
* `RET` - to transfer control back to the address at the top of the stack.
* `PRINT “...”` - prints the string enclosed within quotes on the screen.
* `PRINT X` - prints the value stored in register `X`.
* `EXT` - terminates the program.

## How to run the program

1. Install _Flex_ and _Bison_ tools on the computer, if not already installed.
2. Go to the command prompt (terminal) on the computer and relocate to the directory where the project files have been saved.
3. Run the makefile on the computer, which will produce an executable named `a`
    * `a.exe` - on Windows device.
    * `a.out` - on Linux device.
4. Assuming the name of the input ASM source file to be `sample_input.s`, run the following command on the terminal -
    * `a sample_input.s` - for Windows device.
    * `./a.out sample_input.s` - for Linux device.
5. Obtain the output on the terminal screen.

## How the program works
1. The bison file (_**assem.y**_) is compiled first, which yields a C file _**assem.tab.c**_ and another file _**assem.tab.h**_.
2. The _**assem.tab.c**_ file is then used by the lex file (_**assem.l**_) to yield another C file _**lex.yy.c**_ on compilation, which generates a routine called _**yylex()**_.
3. The gcc (or any other C compiler) compiler is then called upon to compile all the C files (_**main.c**_, _**stack.c**_, _**lex.yy.c**_, _**assem.tab.c**_) together, hence producing an executable
`a.out` (Linux) or `a.exe` (Windows).
4. Commands for steps 1 - 3 are mentioned inside the _**makefile**_, hence running this file alone performs all the above tasks automatically.
5. The executable is run along with the input file (_**sample_input.s**_) on the command line and hence the program starts reading input from the ASM source file line by line.
6. The program runs until either end of the input file is reached or any invalid instruction is encountered.


