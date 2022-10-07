# Language-Evaluator
Project for COMP 141 : Programming Languages

## About
C++ Project that combines our code for a Scanner and Parser and uses that output to now Evaluate a given expression using a Pre-Order traversal of the given Abstract Syntax Tree (AST) by the parser. While traversing the expression in a pre-order fashion, the stack is used to evaluate the top 3 nodes at a time. Checking whether the first two nodes are values and the third being an operator. If this is the case then push back in the evaluated value.

## How to Run
All code was written in Visual Studio Code, in the C++ language.
1. In order to compile type:
- g++ main.cpp -o main
2. Write Expressions in "test_input.txt". And in order to execute main with the text files as the arguments type:
- ./main test_input.txt test_output.txt
3. Open "test_output.txt" to see results.

## Assignment
[PR3.1.pdf](https://github.com/Jabez-J-Lee/Language-Evaluator/files/9730430/PR3.1.pdf)
