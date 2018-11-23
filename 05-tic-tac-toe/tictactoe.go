package main

import (
	"fmt"
	"math"
)

type player int8

const (
	noone player = iota
	human player = iota
	compu player = iota
)

// Board represents a 3x3 tic-tac-toe board
type Board [3][3]player

// Triplet reperesents a set of three players
type triplet [3]player

func (t triplet) isEndGame() (bool, player) {
	if t[0] != t[1] || t[1] != t[2] || t[0] != t[2] {
		return false, noone
	}

	if t[0] == noone {
		return false, noone
	}

	return true, t[0]
}

func (b *Board) row(i uint) triplet {
	return triplet{b[i][0], b[i][1], b[i][2]}
}

func (b *Board) col(j uint) triplet {
	return triplet{b[0][j], b[1][j], b[2][j]}
}

func (b *Board) diag1() triplet {
	return triplet{b[0][0], b[1][1], b[2][2]}
}

func (b *Board) diag2() triplet {
	return triplet{b[0][2], b[1][1], b[2][0]}
}

func (c player) print() {
	var str string

	switch c {
	case noone:
		str = " "
	case human:
		str = "X"
	case compu:
		str = "O"
	}

	fmt.Print(str)
}

func (b *Board) print() {
	for i := 0; i < 3; i++ {
		b[i][0].print()
		fmt.Print("|")
		b[i][1].print()
		fmt.Print("|")
		b[i][2].print()
		fmt.Print("\n")
		if i != 2 {
			fmt.Print("-+-+-\n")
		}
	}
}

func (b *Board) isFull() bool {
	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			if b[i][j] == noone {
				return false
			}
		}
	}

	return true
}

func (b *Board) isEndGame() (bool, player) {
	triplets := make([]triplet, 0, 8)

	triplets = append(
		triplets,
		b.col(0), b.col(1), b.col(2),
		b.row(0), b.row(1), b.row(2),
		b.diag1(), b.diag2())

	for _, t := range triplets {
		isEndGame, player := t.isEndGame()

		if isEndGame {
			return isEndGame, player
		}
	}

	return b.isFull(), noone
}

func (b *Board) emptyFields() int8 {
	var num int8 = 0

	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			if b[i][j] == noone {
				num++
			}
		}
	}

	return num
}

func (b *Board) children(nextPlayer player) []Board {
	result := make([]Board, 0, 9)

	for i := 0; i < 3; i++ {
		for j := 0; j < 3; j++ {
			if b[i][j] == noone {
				newBoard := *b

				newBoard[i][j] = nextPlayer

				result = append(result, newBoard)
			}
		}
	}

	return result
}

func utility(b *Board, winner player) int8 {
	switch winner {
	case noone:
		return 0
	case human:
		return -b.emptyFields()
	case compu:
		return b.emptyFields()
	}

	return 0 // should never be reached
}

func (b *Board) minMaxDecision() Board {
	var v int8 = math.MinInt8
	nextTurn := *b
	endGame, _ := b.isEndGame()

	var alpha int8 = math.MinInt8
	var beta int8 = math.MaxInt8

	if endGame {
		return nextTurn
	}

	for _, child := range b.children(compu) {
		currentV := child.minValue(alpha, beta)

		if currentV > v {
			v = currentV
			nextTurn = child
		}
	}

	return nextTurn
}

func min(values ...int8) int8 {
	var m int8 = math.MaxInt8

	for _, value := range values {
		if value < m {
			m = value
		}
	}

	return m
}

func max(values ...int8) int8 {
	var m int8 = math.MinInt8

	for _, value := range values {
		if value > m {
			m = value
		}
	}

	return m
}

func (b *Board) maxValue(alpha, beta int8) int8 {
	var v int8 = math.MinInt8
	endGame, winner := b.isEndGame()

	if endGame {
		return utility(b, winner)
	}

	for _, child := range b.children(compu) {
		currentV := child.minValue(alpha, beta)

		v = max(currentV, v)
		alpha = max(alpha, currentV)

		if alpha >= beta {
			break
		}
	}

	return v
}

func (b *Board) minValue(alpha, beta int8) int8 {
	var v int8 = math.MaxInt8
	endGame, winner := b.isEndGame()

	if endGame {
		return utility(b, winner)
	}

	for _, child := range b.children(human) {
		currentV := child.maxValue(alpha, beta)

		v = min(v, currentV)
		beta = min(beta, currentV)

		if alpha >= beta {
			break
		}
	}

	return v
}

func HumanInput(currentBoard *Board) {
	var x, y int8 = -1, -1
	firstTurn := true

	moveIsValid := func() bool {
		if x < 1 || x > 3 {
			if !firstTurn {
				fmt.Printf("Invalid turn. %d must be between 1 and 3\n", x)
			}
			return false
		}

		if y < 1 || y > 3 {
			if !firstTurn {
				fmt.Printf("Invalid turn. %d must be between 1 and 3\n", y)
			}
			return false
		}

		if currentBoard[x-1][y-1] != noone {
			if !firstTurn {
				fmt.Printf("Invalid turn. Cell already taken\n")
			}
			return false
		}

		return true
	}

	for !moveIsValid() {
		fmt.Printf("Enter your turn, Human: ")
		fmt.Scanf("%d %d", &y, &x)
		firstTurn = false
	}

	currentBoard[x-1][y-1] = human
}

func ComputerInput(currentBoard *Board) {
	*currentBoard = currentBoard.minMaxDecision()
}

func main() {
	currentPlayer := noone
	currentBoard := new(Board)

	var gameOver = false
	var winner = noone

	for currentPlayer != human && currentPlayer != compu {
		fmt.Println("Who's playing first? 1 = human, 2 = computer")
		fmt.Scanf("%d", &currentPlayer)
	}

	for ; !gameOver; gameOver, winner = currentBoard.isEndGame() {
		if currentPlayer == compu {
			ComputerInput(currentBoard)
			currentPlayer = human
			currentBoard.print()
		} else {
			HumanInput(currentBoard)
			currentPlayer = compu
		}
	}

	fmt.Println("Game over. Winner is: ")

	switch winner {
	case noone:
		fmt.Println("Noone :)")
	case human:
		fmt.Println("Human")
	case compu:
		fmt.Println("Computer")
	}
}
