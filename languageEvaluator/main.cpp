// Jabez Lee and Ben Ayers
//  Project Phase 3.1 Evaluator

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <regex>
#include <stdexcept>
#include <vector>

using namespace std;

ifstream inputFile;
ofstream outputFile;

struct Token
{
    string value;
    string type;
};

class Node
{
public:
    Node * left, * middle, * right;
    Token data;
    Node(Token token)
    {
        data = token;
        left = NULL;
        middle = NULL;
        right = NULL;
    }

    // insert subtree into left of node
    Node * insertLeft(Node *tree, Node *subtree)
    {
        tree->left = subtree;
        return tree;
    }

    // insert subtree into middle Node
    Node * insertMiddle(Node *tree, Node *subTree)
    {
        tree->middle = subTree;
        return tree;
    }

    // insert subtree into right Node
    Node * insertRight(Node *tree, Node *subTree)
    {
        tree->right = subTree;
        return tree;
    }
};

int depth(Node * tree)
{
    if (tree == NULL)
        return 0;
    int leftdepth = depth(tree->left);
    int rightdepth = depth(tree->right);
    if (leftdepth > rightdepth)
        return leftdepth + 1;
    return rightdepth + 1;
}

Node * newNode(Token token, Node * left, Node * middle, Node * right)
{
    Node * node = new Node(token);
    node->left = left;
    node->middle = middle;
    node->right = right;
    return node;
}

Token getToken(vector<Token> tokenList, int * currentIndex)
{
    if (*currentIndex >= tokenList.size())
    {
        Token empty = {"", ""};
        return empty;
    }
    return tokenList[*currentIndex];
}

Node * parseExp(vector<Token> tokenList, int * currentIndex);

Node * parseElem(vector<Token> tokenList, int * currentIndex)
{
    Node * t;
    if (tokenList[*currentIndex].value == "(")
    {
        (*currentIndex)++;
        t = parseExp(tokenList, currentIndex);
        if (getToken(tokenList, currentIndex).value == ")")
        {
            (*currentIndex)++;
            return t;
        }
        else
        {
            outputFile << "Error at Token: " << getToken(tokenList, currentIndex).value << endl;
            throw invalid_argument("Incorrect Syntax");
        }
    }

    else
    {
        if (tokenList[*currentIndex].type == " : Number" ||
            tokenList[*currentIndex].type == " : Identifier")
        {
            Token token = getToken(tokenList, currentIndex);
            (*currentIndex)++;
            t = newNode(token, NULL, NULL, NULL);
            return t;
        }
        else
        {
            outputFile << "Error at Token: " << getToken(tokenList, currentIndex).value << endl;
            throw invalid_argument("Incorrect Syntax");
        }
    }
}

Node * parsePiece(vector<Token> tokenList, int * currentIndex)
{
    Node * t = parseElem(tokenList, currentIndex);
    while (getToken(tokenList, currentIndex).value == "*")
    {
        Token token = tokenList[*currentIndex];
        (*currentIndex)++;
        t = newNode(token, t, NULL, parseElem(tokenList, currentIndex));
    }
    return t;
}

Node * parseFactor(vector<Token> tokenList, int * currentIndex)
{
    Node * t = parsePiece(tokenList, currentIndex);
    while (getToken(tokenList, currentIndex).value == "/")
    {
        Token token = tokenList[*currentIndex];
        (*currentIndex)++;
        t = newNode(token, t, NULL, parsePiece(tokenList, currentIndex));
    }
    return t;
}

Node * parseTerm(vector<Token> tokenList, int * currentIndex)
{
    Node *t = parseFactor(tokenList, currentIndex);
    while (getToken(tokenList, currentIndex).value == "-")
    {
        Token token = tokenList[*currentIndex];
        (*currentIndex)++;
        t = newNode(token, t, NULL, parseFactor(tokenList, currentIndex));
    }
    return t;
}

Node * parseExp(vector<Token> tokenList, int * currentIndex)
{
    Node * t = parseTerm(tokenList, currentIndex);
    while (getToken(tokenList, currentIndex).value == "+")
    {
        Token token = tokenList[*currentIndex];
        (*currentIndex)++;
        t = newNode(token, t, NULL, parseTerm(tokenList, currentIndex));
    }
    return t;
}

bool canEvaluate(vector<Token> stack){
    return stack.size() >= 3 &&
     stack[stack.size() - 1].type == " : Number" && 
     stack[stack.size() - 2].type == " : Number" && 
     stack[stack.size() - 3].type == " : Symbol";
}

vector<Token> evaulator(vector<Token> stack) {
    int num2 = stoi(stack[stack.size() - 1].value);
    int num1 = stoi(stack[stack.size() - 2].value);
    string op = stack[stack.size() - 3]. value;
    int result;
    Token resultToken;

    if(op == "+"){
        result = num1 + num2;
    }
    else if(op == "-"){
        result = num1 - num2;
    }
    else if(op == "*"){
        result = num1 * num2;
    }
    else if(op == "/"){
        result = num1 / num2;
    }

    stack.pop_back();
    stack.pop_back();
    stack.pop_back();

    resultToken = *(new Token {to_string(result), " : Number"});
    stack.push_back(resultToken);

    return stack;
}

vector<Token> createStack(Node * tree)
{
    vector<Token> stack = {};

    if(tree == NULL) return stack;

    stack.push_back(tree->data);

    while(canEvaluate(stack)){
        stack = evaulator(stack);
    }
    vector<Token> newStack = createStack(tree -> left);
    stack.insert(stack.end(), newStack.begin(), newStack.end()); // Appending newStack to stack

    while(canEvaluate(stack)){
        stack = evaulator(stack);
    }
    newStack = createStack(tree -> middle);
    stack.insert(stack.end(), newStack.begin(), newStack.end());
    
    while(canEvaluate(stack)){
        stack = evaulator(stack);
    }
    newStack = createStack(tree -> right);
    stack.insert(stack.end(), newStack.begin(), newStack.end());

    while(canEvaluate(stack)){
        stack = evaulator(stack);
    }

    return stack;
}

void pre_tr(Node * t, int level)
{
    if (t == NULL)
        return;
    // Root
    outputFile << std::string(level, '\t') << t->data.value << t->data.type << endl;

    // Evaluator
    // push(st, t.root)
    // Check Top 3 Element

    // Node Traversal
    pre_tr(t->left, level + 1);
    pre_tr(t->middle, level + 1);
    pre_tr(t->right, level + 1);
}

void parser(vector<Token> tokenList)
{
    outputFile << "AST: " << endl;
    Node *ast;
    int currentVal = 0;
    try
    {
        ast = parseExp(tokenList, &currentVal);
    }
    catch (invalid_argument &e)
    {
        cerr << e.what() << endl;
        return;
    }
    vector<Token> stack = createStack(ast);
    
    pre_tr(ast, 0);

    if(stoi(stack[0].value) < 1){
        outputFile << "Result is: " << 0 << endl;
    }
    else{
        outputFile << "Result is: " << stack[0].value << endl;
    }
    
    outputFile << endl;
}

void scanner(vector<string> stringList)
{
    string results[100];
    string identifier = " : Identifier";
    string number = " : Number";
    string symbol = " : Symbol";
    string keyword = " : Keyword";
    string error = " caused an error";

    regex id("([a-z]|[A-Z])([a-z]|[A-Z]|[0-9])*");
    regex num("[0-9]+");
    regex symb("\\+|\\*|\\(|\\)|\\-|\\/|:=|;");
    regex key("if|then|else|endif|while|do|endwhile|skip");
    regex space(" +");

    int stringLength = stringList.size();

    vector<Token> tokenList;

    outputFile << "Tokens: " << endl;
    for (int i = 0; i < stringLength; i++)
    {
        for (int j = 0; j < stringList[i].size(); j++)
        {
            string currentChar = string(1, stringList[i][j]);
            string nextChar;
            int currentIndex = j + 1;
            string combine;

            if (regex_match(currentChar, id))
            {
                combine = currentChar;
                nextChar = string(1, stringList[i][currentIndex]);
                while ((regex_match(nextChar, id) || regex_match(nextChar, num)) && currentIndex < stringList[i].size())
                {
                    combine = currentChar += nextChar;
                    j = currentIndex;
                    currentIndex += 1;
                    nextChar = string(1, stringList[i][currentIndex]);
                }

                if (regex_match(combine, key))
                {
                    Token token = {combine, keyword};
                    tokenList.push_back(token);
                }
                else
                {
                    Token token = {combine, identifier};
                    tokenList.push_back(token);
                }
            }
            else if (regex_match(currentChar, num))
            {
                combine = currentChar;
                nextChar = string(1, stringList[i][currentIndex]);
                while (regex_match(nextChar, num) && currentIndex < stringList[i].size())
                {
                    combine = currentChar += nextChar;
                    j = currentIndex;
                    currentIndex += 1;
                    nextChar = string(1, stringList[i][currentIndex]);
                }
                Token token = {combine, number};
                tokenList.push_back(token);
            }
            else if (regex_match(currentChar, symb))
            {
                combine = currentChar;
                nextChar = string(1, stringList[i][currentIndex]);

                Token token = {combine, symbol};
                tokenList.push_back(token);
            }
            else if (regex_match(currentChar, space))
            {
                continue;
            }
            else
            {
                nextChar = string(1, stringList[i][currentIndex]);
                if (currentChar == ":" && nextChar == "=")
                {
                    combine = currentChar += nextChar;
                    j = currentIndex;
                    currentIndex += 1;
                    Token token = {combine, symbol};
                    tokenList.push_back(token);
                }
                else
                {
                    outputFile << currentChar << error << endl;
                }
            }
        }
    }
    for (int i = 0; i < tokenList.size(); i++)
    {
        outputFile << tokenList[i].value << tokenList[i].type << endl;
    }

    parser(tokenList);
}

void readFile(string inputText, string outputText)
{
    ifstream inputFile;
    string line;
    vector<string> modLine;

    inputFile.open(inputText);
    outputFile.open(outputText);
    if (inputFile.is_open())
    {
        while (getline(inputFile, line))
        {
            // SKips empty Lines
            if (line.length() == 0)
            {
                continue;
            }

            // Outputs the line and sends char stream to scanner
            outputFile << "Line: " << line << endl;
            istringstream iss(line);
            for (line; iss >> line;)
            {
                modLine.push_back(line);
            }
            scanner(modLine);
            modLine.clear();
        }
    }
    else
    {
        cout << "This file could not be found, Please check the file name and try again." << endl;
    }
    inputFile.close();
    outputFile.close();
}

int main(int argc, char *argv[])
{
    if (argc > 5)
    {
        cout << "You have entered too many arguments. Please Try Again" << endl;
    }
    else
    {
        readFile(argv[1], argv[2]);
    }
    return 0;
}
