package models

import (
	"fmt"
	"hash/crc32"
	"io"
	"sync"

	"golang.org/x/xerrors"
)

// CIDSuffixLength sets the length to truncate the CID in dot syntax production
const CIDSuffixLength = 16

// Block represents a single node to be visualized
type Block struct {
	CID          string `pg:"cid"`
	Height       uint64 `pg:"height"`
	ParentCID    string `pg:"parent_cid"`
	ParentHeight uint64 `pg:"parent_height"`
	Miner        string `pg:"miner"`
}

// WriteTo outputs DOT syntax to be drawn by graphviz dot. Implements the
// WriterTo interface.
func (b *Block) WriteTo(out io.Writer) (int, error) {
	var bytesWritten int
	var blockParent = b.parentShort()

	// Check for null blocks between this block and its parent. If any, create
	// placeholders for them in the DOT output.
	var nulls = b.Height - b.ParentHeight - 1
	for i := uint64(0); i < nulls; i++ {
		height := b.Height - nulls + i
		name := b.blockShort() + "NB" + fmt.Sprint(i)
		label := "NULL:" + fmt.Sprint(height)
		n, err := fmt.Fprintf(out,
			"%s [label = \"%s\", fillcolor = \"#ffddff\"]\n"+
				"%s -> %s\n",
			name,
			label,
			name,
			blockParent,
		)
		if err != nil {
			return bytesWritten + n, xerrors.Errorf("writing null %d: %w", name, err)
		}
		bytesWritten += n
		blockParent = name
	}

	// Print the block itself
	n, err := fmt.Fprintf(out,
		"%s [label = \"%s:%d\\n%s\", fillcolor = \"#%06x\"]\n"+
			"%s -> %s\n",
		b.blockShort(),
		b.Miner,
		b.Height,
		b.blockShort(),
		b.dotColor(),
		b.blockShort(),
		blockParent,
	)
	return bytesWritten + n, err
}

var defaultTbl = crc32.MakeTable(crc32.Castagnoli)

// dotColor intends to convert the Miner id into the RGBa color space
func (b *Block) dotColor() uint32 {
	return crc32.Checksum([]byte(b.Miner), defaultTbl)&0xc0c0c0c0 + 0x30303000 | 0x000000ff
}

// blockShort is a truncated representation of Block.CID
func (b *Block) blockShort() string {
	return fmt.Sprintf("%s_%s", b.CID[0:4], b.CID[len(b.CID)-CIDSuffixLength:])
}

// parentShort is a truncated representation of Block.ParentCID
func (b *Block) parentShort() string {
	return fmt.Sprintf("%s_%s", b.ParentCID[0:4], b.ParentCID[len(b.ParentCID)-CIDSuffixLength:])
}

// BlockSet represents a collection of Blocks to be visualized
type BlockSet struct {
	blocks []*Block
	labels sync.Map
}

// NewBlockSet returns a BlockSet when given a slice of *Blocks
func NewBlockSet(blks []*Block) *BlockSet {
	return &BlockSet{blocks: blks}
}

// WriteTo outputs DOT syntax of the BlockSet to be drawn by graphviz dot.
// Implements the WriterTo interface.
func (bs *BlockSet) WriteTo(out io.Writer) (int, error) {
	bytesWritten, err := fmt.Fprintf(out, "digraph D {\n")
	if err != nil {
		return bytesWritten, xerrors.Errorf("writing intro: %w", err)
	}
	for _, blk := range bs.blocks {
		n, err := blk.WriteTo(out)
		if err != nil {
			return bytesWritten + n, xerrors.Errorf("writing block %s: %w", blk.CID, err)
		}
		bytesWritten += n
	}
	n, err := fmt.Fprintf(out, "}\n")
	if err != nil {
		return bytesWritten + n, xerrors.Errorf("writing outro: %w", err)
	}
	return bytesWritten + n, nil
}
