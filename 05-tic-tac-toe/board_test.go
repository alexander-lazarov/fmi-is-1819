package main

import (
	"fmt"
	"testing"
)

func TestTripletIsEndGame(t *testing.T) {
	var tests = []struct {
		input   triplet
		output1 bool
		output2 player
	}{
		{
			input:   triplet{noone, noone, noone},
			output1: false,
			output2: noone,
		},
		{
			input:   triplet{compu, compu, noone},
			output1: false,
			output2: noone,
		},
		{
			input:   triplet{compu, compu, compu},
			output1: true,
			output2: compu,
		},
		{
			input:   triplet{human, human, compu},
			output1: false,
			output2: noone,
		},
		{
			input:   triplet{human, human, human},
			output1: true,
			output2: human,
		},
	}

	for i, test := range tests {
		t.Run(fmt.Sprintf("Board %d", i), func(t *testing.T) {
			isEndGame, player := test.input.isEndGame()

			if isEndGame != test.output1 || player != test.output2 {
				t.Errorf("%#v.isEndGame() not correct, expected %v %v", test.input, test.output1, test.output2)
			}
		})
	}
}

func TestBoardIsFull(t *testing.T) {
	var tests = []struct {
		input  Board
		output bool
	}{
		{
			input: Board{
				{noone, noone, noone},
				{noone, noone, noone},
				{noone, noone, noone}},
			output: false,
		},
		{
			input: Board{
				{noone, noone, noone},
				{noone, compu, noone},
				{noone, noone, noone}},
			output: false,
		},
		{
			input: Board{
				{noone, noone, compu},
				{human, compu, human},
				{compu, noone, noone}},
			output: false,
		},
		{
			input: Board{
				{human, compu, compu},
				{compu, compu, human},
				{human, human, compu}},
			output: true,
		},
	}

	for i, test := range tests {
		t.Run(fmt.Sprintf("Board %d", i), func(t *testing.T) {
			isFull := test.input.isFull()

			if isFull != test.output {
				t.Errorf("%#v.isFull() not correct, expected %v", test.input, test.output)
			}
		})
	}
}

func TestBoardIsEndGame(t *testing.T) {
	var tests = []struct {
		input   Board
		output1 bool
		output2 player
	}{
		{
			input: Board{
				{noone, noone, noone},
				{noone, noone, noone},
				{noone, noone, noone}},
			output1: false,
			output2: noone,
		},
		{
			input: Board{
				{noone, noone, noone},
				{noone, compu, noone},
				{noone, noone, noone}},
			output1: false,
			output2: noone,
		},
		{
			input: Board{
				{noone, noone, compu},
				{human, compu, human},
				{compu, noone, noone}},
			output1: true,
			output2: compu,
		},
		{
			input: Board{
				{human, compu, compu},
				{compu, compu, human},
				{human, human, compu}},
			output1: true,
			output2: noone,
		},
	}

	for i, test := range tests {
		t.Run(fmt.Sprintf("Board %d", i), func(t *testing.T) {
			endgame, player := test.input.isEndGame()

			if endgame != test.output1 || player != test.output2 {
				t.Errorf("%#v.isEndGame() not correct, expected %v %v", test.input, test.output1, test.output2)
			}
		})
	}
}

func TestMinMaxDecision(t *testing.T) {
	var tests = []struct {
		input  Board
		output Board
	}{
		{
			input: Board{
				{noone, noone, noone},
				{noone, noone, noone},
				{noone, noone, noone}},
			output: Board{
				{compu, noone, noone},
				{noone, noone, noone},
				{noone, noone, noone}},
		},
		{
			input: Board{
				{human, noone, noone},
				{noone, noone, noone},
				{noone, noone, noone}},
			output: Board{
				{human, noone, noone},
				{noone, compu, noone},
				{noone, noone, noone}},
		},
		{
			input: Board{
				{noone, noone, noone},
				{noone, human, noone},
				{noone, noone, noone}},
			output: Board{
				{compu, noone, noone},
				{noone, human, noone},
				{noone, noone, noone}},
		},
		{
			input: Board{
				{compu, noone, noone},
				{noone, human, noone},
				{human, noone, noone}},
			output: Board{
				{compu, noone, compu},
				{noone, human, noone},
				{human, noone, noone}},
		},
		{
			input: Board{
				{compu, noone, compu},
				{noone, human, noone},
				{human, noone, human}},
			output: Board{
				{compu, compu, compu},
				{noone, human, noone},
				{human, noone, human}},
		},
	}

	for i, test := range tests {
		t.Run(fmt.Sprintf("Board %d", i), func(t *testing.T) {
			result := test.input.minMaxDecision()

			if result != test.output {
				t.Errorf("%v.isFull() not correct, expected %v, got %v", test.input, test.output, result)
			}
		})
	}
}
