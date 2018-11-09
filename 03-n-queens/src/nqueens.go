package main

import (
	"fmt"
	"math"
	"math/rand"
	"strings"
	"time"
)

// Board represents a board arrangement
type Board struct {
	n         int
	queens    []int
	conflicts [][]int
	seed      rand.Source
}

// RowConflicts returns the number of queens on row x
// exlcuding the queen on column y
func (b *Board) RowConflicts(x, y int) int {
	result := 0

	for _, j := range b.queens {
		if j == y {
			result++
		}
	}

	if (*b).queens[x] == y {
		result--
	}

	return result
}

func (b *Board) QueenMoves(x, y int, f func(int, int)) {
	for i := 0; i < b.n; i++ {
		if x == i {
			continue
		}

		diff := x - y
		sum := x + y

		f(i, y)

		j1 := i - diff
		if 0 <= j1 && j1 < b.n {
			f(i, j1)
		}

		j2 := sum - i
		if 0 <= j2 && j2 < b.n {
			f(i, j2)
		}
	}
}

func (b *Board) IsSolution() bool {
	for i := range b.queens {
		if b.conflicts[i][b.queens[i]] != 0 {
			return false
		}
	}

	return true
}

func (b *Board) MinimizeConflictsForColumn(x int) bool {
	var newY int
	min := b.n
	l := 0
	minJ := make([]int, b.n)
	oldY := b.queens[x]

	for j := 0; j < b.n; j++ {
		currentConflicts := b.conflicts[x][j]

		if currentConflicts < min {
			l = 1
			min = currentConflicts
			minJ[0] = j
		} else if currentConflicts == min {
			minJ[l] = j
			l++
		}
	}

	newY = minJ[rand.Intn(l)]

	if newY == oldY {
		return false
	}

	b.moveQueen(x, oldY, newY)

	return true
}

func (b *Board) moveQueen(x, oldY, newY int) {
	b.queens[x] = newY

	b.QueenMoves(x, newY, func(x, y int) {
		b.conflicts[x][y]++
	})

	b.QueenMoves(x, oldY, func(x, y int) {
		b.conflicts[x][y]--
	})
}

func (b *Board) MinimizeConflicts() bool {
	return b.MinimizeConflictsForColumn(
		b.MaxConflicts())
}

func (b *Board) MaxConflicts() int {
	max := 0
	l := 0
	var maxI []int

	maxI = make([]int, b.n)

	for i := range b.queens {
		currentConflicts := b.conflicts[i][b.queens[i]]

		if currentConflicts > max {
			max = currentConflicts
			l = 1
			maxI[0] = i
		} else if currentConflicts == max {
			maxI[l] = i
			l++
		}
	}

	if l == 0 {
		return 0
	}

	return maxI[rand.Intn(l)]
}

func (b *Board) initConflictsTable() {
	b.conflicts = make([][]int, b.n)

	for i := 0; i < b.n; i++ {
		b.conflicts[i] = make([]int, b.n)
	}

	for i := 0; i < b.n; i++ {
		b.QueenMoves(i, b.queens[i], func(x, y int) {
			b.conflicts[x][y]++
		})
	}
}

// InitBoard creates a new n*n board
func InitBoard(n int) Board {
	source := rand.NewSource(time.Now().UnixNano())
	board := Board{
		queens: rand.Perm(n),
		n:      n,
		seed:   source,
	}

	board.initConflictsTable()

	return board
}

func main() {
	var n int
	var board Board
	var foundSolution = false

	fmt.Scanf("%d", &n)

	maxAttempts := n * (int)(math.Log2((float64)(n)))

	for !foundSolution {
		board = InitBoard(n)

		failToMinimizeCounter := 0

		for attempts := 0; attempts < maxAttempts; attempts++ {
			if board.IsSolution() {
				foundSolution = true

				break
			}

			if !board.MinimizeConflicts() {
				failToMinimizeCounter++

				if failToMinimizeCounter > maxAttempts {
					break
				}
			} else {
				failToMinimizeCounter = 0
			}
		}
	}

	// fmt.Printf("%v\n", board.queens)

	for i := 0; i < n; i++ {
		fmt.Printf("%s%s%s\n",
			strings.Repeat("_ ", board.queens[i]), "* ", strings.Repeat("_ ", n-board.queens[i]-1))
	}
}
