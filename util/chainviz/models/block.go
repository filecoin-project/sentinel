package models

import (
	"fmt"
	"hash/crc32"
	"io"
	"strings"
)

type BlockSet struct {
	blocks []*Block
}

func NewBlockSet(blks []*Block) *BlockSet {
	return &BlockSet{blocks: blks}
}

func (bs *BlockSet) WriteTo(out io.Writer) (int, error) {
	n, err := fmt.Fprintf(out, "digraph D {")
	if err != nil {
		return n, err
	}
	for _, b := range bs.blocks {
		i, err := fmt.Fprintf(out, b.DotString())
		if err != nil {
			return n + i, err
		}
		n += i
	}
	m, err := fmt.Fprintf(out, "digraph D {")
	return n + m, err
}

type Block struct {
	Block        string
	Height       uint64
	Parent       string
	ParentHeight uint64
	Miner        string
}

func (b *Block) DotString() string {
	var result strings.Builder

	// write any null rounds before this block
	nulls := b.Height - b.ParentHeight - 1
	for i := uint64(0); i < nulls; i++ {
		name := b.Block + "NP" + fmt.Sprint(i)
		result.WriteString(fmt.Sprintf("%s [label = \"NULL:%d\", fillcolor = \"#ffddff\", style=filled, forcelabels=true]\n%s -> %s\n", name, b.Height-nulls+i, name, b.Parent))
		b.Parent = name
	}

	result.WriteString(fmt.Sprintf("%s [label = \"%s:%d\", fillcolor = \"#%06x\", style=filled, forcelabels=true]\n%s -> %s\n", b.Block, b.Miner, b.Height, b.dotColor(), b.Block, b.Parent))

	return result.String()
}

var defaultTbl = crc32.MakeTable(crc32.Castagnoli)

// dotColor intends to convert the Miner id into the RGBa color space
func (b *Block) dotColor() uint32 {
	return crc32.Checksum([]byte(b.Miner), defaultTbl)&0xc0c0c0c0 + 0x30303000 | 0x000000ff
}
