package models

import (
	"fmt"
	"hash/crc32"
	"io"
	"sync"

	"golang.org/x/xerrors"
)

const CIDSuffixLength = 16

type Block struct {
	Block        string
	Height       uint64
	Parent       string
	ParentHeight uint64
	Miner        string
}

func (b *Block) WriteTo(out io.Writer) (int, error) {
	var bytesWritten int
	var nulls = b.Height - b.ParentHeight - 1
	var blockParent = b.parentShort()

	// write null blocks if present
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

func (b *Block) blockShort() string {
	return fmt.Sprintf("%s_%s", b.Block[0:4], b.Block[len(b.Block)-CIDSuffixLength:])
}

func (b *Block) parentShort() string {
	return fmt.Sprintf("%s_%s", b.Parent[0:4], b.Parent[len(b.Parent)-CIDSuffixLength:])
}

type BlockSet struct {
	blocks []*Block
	labels sync.Map
}

func NewBlockSet(blks []*Block) *BlockSet {
	return &BlockSet{blocks: blks}
}

func (bs *BlockSet) WriteTo(out io.Writer) (int, error) {
	bytesWritten, err := fmt.Fprintf(out, "digraph D {\n")
	if err != nil {
		return bytesWritten, xerrors.Errorf("writing intro: %w", err)
	}
	for _, blk := range bs.blocks {
		n, err := blk.WriteTo(out)
		if err != nil {
			return bytesWritten + n, xerrors.Errorf("writing block %s: %w", blk.Block, err)
		}
		bytesWritten += n
	}
	n, err := fmt.Fprintf(out, "}\n")
	if err != nil {
		return bytesWritten + n, xerrors.Errorf("writing outro: %w", err)
	}
	return bytesWritten + n, nil
}
