package main

import (
	"fmt"
	"math/rand"
	"sort"
	"time"
)

type Item struct {
	weight int
	price  int
}

type Knapsack struct {
	items  []bool
	price  int
	weight int
}

type Population []Knapsack

func (k *Knapsack) RefreshTotals() {
	k.price = 0
	k.weight = 0

	for i := 0; i < n; i++ {
		if k.items[i] {
			k.price += availableItems[i].price
			k.weight += availableItems[i].weight
		}
	}
}

func (k *Knapsack) IsOverflowing() bool {
	return k.weight > maxWeight
}

func RandomKnapsack() *Knapsack {
	k := EmptyKnapsack()

	for i := range k.items {
		k.items[i] = randGen.Intn(2) == 0
	}

	k.RefreshTotals()

	return k
}

func (k *Knapsack) Mutate() Knapsack {
	i := randGen.Intn(n)
	j := randGen.Intn(n)

	c := k.Copy()

	if i == j || c.items[i] == c.items[j] {
		c.items[i] = !c.items[i]
	} else {
		c.items[i], c.items[j] = c.items[j], c.items[i]
	}

	c.RefreshTotals()

	return *c
}

func EmptyKnapsack() *Knapsack {
	k := new(Knapsack)
	k.items = make([]bool, n)

	for i := range k.items {
		k.items[i] = false
	}

	return k
}

func (k *Knapsack) Copy() *Knapsack {
	newK := new(Knapsack)

	newK.items = make([]bool, len(k.items))
	copy(newK.items, k.items)

	return newK
}

func (p *Population) GenerateInitial() {

	*p = make(Population, 0, populationLimit*2)
	*p = append(*p, *EmptyKnapsack())

	p.AddRandom(populationLimit * 2)

	p.Sort()
}

func (p *Population) AddRandom(num int) {
	var k *Knapsack

	for i := 0; i < num; i++ {
		k = RandomKnapsack()

		*p = append(*p, *k)
	}
}

func (p *Population) Sort() {
	sortFunc := func(i, j int) bool {
		var io = (*p)[i].IsOverflowing()
		var jo = (*p)[j].IsOverflowing()

		if io {
			if jo {
				return (*p)[i].price < (*p)[j].price
			} else {
				return false
			}
		} else {
			if jo {
				return true
			} else {
				return (*p)[i].price >= (*p)[j].price
			}
		}
	}

	sort.Slice(currentPopulation, sortFunc)
}

func (p *Population) Mutate(target *Population) {
	var mutationCount = (len(*p) * mutationPercentage) / 100

	for i := 0; i < mutationCount; i++ {
		var mutated Knapsack

		if i%2 == 0 {
			mutated = (*p)[i].Mutate()
		} else {
			mutated = (*p)[randGen.Intn(len(*p))].Mutate()
		}

		*target = append(*target, mutated)
	}
}

func CrossCouple(k1, k2 *Knapsack) (r1, r2 *Knapsack) {
	m1 := k1.Copy()
	m2 := k2.Copy()

	for _, i := range randGen.Perm(n)[:randGen.Intn(n)] {
		m1.items[i] = k2.items[i]
		m2.items[i] = k1.items[i]
	}

	m1.RefreshTotals()
	m2.RefreshTotals()

	return m1, m2
}

func (p *Population) Crossover(target *Population) {
	for i := 0; i < n/2; i++ {
		i1 := rand.Intn(len(*p))
		i2 := rand.Intn(len(*p))

		k1 := &(*p)[i1]
		k2 := &(*p)[i2]

		n1, n2 := CrossCouple(k1, k2)

		*target = append(*target, *n1, *n2)
	}
}

func (p *Population) Purge() {
	if len(*p) > populationLimit {
		*p = (*p)[:populationLimit]
	}
}

var maxWeight, n int
var availableItems []Item
var randSrc = rand.NewSource(time.Now().UnixNano())
var randGen = rand.New(randSrc)
var currentPopulation Population
var populationLimit = 1000
var mutationPercentage = 30

func main() {
	var best = 0
	var noChangeRuns = 0
	var i int

	fmt.Scanf("%d %d", &maxWeight, &n)

	availableItems = make([]Item, n)

	for i := 0; i < n; i++ {
		fmt.Scanf("%d %d", &availableItems[i].weight, &availableItems[i].price)
	}

	currentPopulation.GenerateInitial()

	for i = 0; noChangeRuns < n; i++ {
		currentPopulation.Crossover(&currentPopulation)
		currentPopulation.Mutate(&currentPopulation)
		currentPopulation.Sort()
		currentPopulation.Purge()

		if best != currentPopulation[0].price {
			best = currentPopulation[0].price
			noChangeRuns = 0

			fmt.Println(currentPopulation[0].price, i)
		} else {
			noChangeRuns++
		}
	}

	fmt.Println(currentPopulation[0].price)
}
