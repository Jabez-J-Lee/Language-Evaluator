#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "connectFour.h"

int maxRow = 6;
int maxCol = 9;
char board[54];

char human = 'H';
char comp = 'C';

uint32_t m_w;
uint32_t m_z;

uint32_t get_random()
{
    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
    return (m_z << 16) + m_w; /* 32-bit result */
}

uint32_t random_in_range(uint32_t low, uint32_t high)
{
    uint32_t range = high - low + 1;
    uint32_t rand_num = get_random();

    return (rand_num % range) + low;
}

int main()
{
    printf("Welcome to Connect Four, Five-in-a-Row Variant\n");
    printf("Version 1.0\n");
    printf("Implemented by Jabez Lee\n");
    printf("Enter two positive numbers to initialize the random number generator.\n");

    scanf("%d\n", &m_w);
    scanf("%d", &m_z);

    printf("Human player (H)\nComputer player (C)\n");

    int coinToss = random_in_range(0, 1);
    if (coinToss)
    {
        printf("Coin Toss...HUMAN goes first\n");
    }
    else
    {
        printf("Coin Toss...COMPUTER goes first\n");
    }

    setupBoard();
    printBoard(board);

    while (!isFull(board))
    {
        int winCon = gameLoop(coinToss, board);
        if (winCon == 2){
            printBoard(board);
            printf("HUMAN Won\n");
            break;
        }
        if(winCon == 1){
            printBoard(board);
            printf("COMPUTER Won\n");
            break;
        }
    }

    // j x maxCol + i
}

void setupBoard()
{
    for (int i = 0; i < 54; i++)
    {
        board[i] = '-';
    }

    board[0] = 'C';
    board[8] = 'C';
    board[9] = 'H';
    board[17] = 'H';
    board[18] = 'C';
    board[26] = 'C';
    board[27] = 'H';
    board[35] = 'H';
    board[36] = 'C';
    board[44] = 'C';
    board[45] = 'H';
    board[53] = 'H';
}

void printBoard(char *board)
{
    printf(" ");
    for (int i = 1; i < 8; i++)
    {
        printf(" %d", i);
    }
    printf("\n");

    for (int j = 0; j < 6; j++)
    {
        for (int i = 0; i < 9; i++)
        {
            printf("%c ", board[9 * j + i]);
        }
        printf("\n");
    }

    printf(" ");
    for (int i = 0; i < 15; i++)
    {
        printf("-");
    }
    printf("\n");
}

int humanTurn(char *board)
{
    int playerCol;
    int cell;
    do
    {
        printf("What column would you like to drop token into? Enter 1-7: ");
        scanf("%d", &playerCol);

        while (playerCol > 7 || playerCol < 0)
        {
            printf("What column would you like to drop token into? Enter 1-7: ");
            scanf("%d", &playerCol);
        }
        cell = dropToken(board, playerCol);
        if (cell < 0)
        {
            printf("Column is full\n");
        }
    } while (cell < 0);
    board[cell] = human;
    return cell;
}

int computerTurn(char *board)
{
    int compCol;
    int cell;
    do
    {
        compCol = random_in_range(1, 7);
        cell = dropToken(board, compCol);
    } while (cell < 0);
    printf("Computer chose Column: %d\n", compCol);
    board[cell] = comp;
    return cell;
}

int dropToken(char *board, int colNum)
{
    int currentCell = maxRow * maxCol - maxCol + colNum;
    while (board[currentCell] != '-' && currentCell > 0)
    {
        currentCell -= maxCol;
    }
    return currentCell;
}

int gameLoop(int firstPlayer, char *board)
{
    if (firstPlayer)
    {
        if (checkWin(board, humanTurn(board)))
            return 2;
        printBoard(board);

        if (checkWin(board, computerTurn(board)))
            return 1;
        printBoard(board);
    }
    else
    {
        if (checkWin(board, computerTurn(board)))
            return 1;
        printBoard(board);

        if (checkWin(board, humanTurn(board)))
            return 2;
        printBoard(board);
    }
    return 0;
}

int checkWin(char *board, int lastCell)
{
    if (checkDirection(board, -(maxCol + 1), lastCell))
    {
        return 1;
    }
    else if (checkDirection(board, -(maxCol), lastCell))
    {
        return 1;
    }
    else if (checkDirection(board, -(maxCol - 1), lastCell))
    {
        return 1;
    }
    else if (checkDirection(board, -1, lastCell))
    {
        return 1;
    }
    return 0;
}

int isFull(char * board){
    for(int i = 0 ; i < 9; i++){
        if(board[i] == '-') return 0;
    }
    return 1;
}

int checkDirection(char *board, int direction, int lastCell)
{
    int counter = 1;
    int currCell;
    for (int i = 0; i < 2; i++)
    {
        currCell = lastCell + direction;
        while (board[currCell] == board[lastCell])
        {
            counter++;
            if (currCell % maxCol == 0 || currCell % maxCol == maxCol - 1)
                break;
            currCell += direction;
            if (currCell < 0)
                break;
        }
        direction *= -1;
    }
    return counter >= 5;
}