package chainviz

import (
	"context"

	"github.com/go-pg/pg/v10"

	"github.com/filecoin-project/sentinel/util/chainviz/models"
)

func Query(ctx context.Context, db *pg.DB, minHeight, chainLength uint64) (*models.BlockSet, error) {
	var (
		endHeight = minHeight + chainLength

		blks = make([]*models.Block, chainLength*5)
	)

	_, err := db.QueryContext(ctx, &blks, `
with block_parents as (
	select
		miner_id,
		header_cid,
		regexp_split_to_table(parents, E',') as parent_header_cid
	from observed_headers
	where unix_to_height(header_timestamp) >= ? and unix_to_height(header_timestamp) <= ?
	group by 1, 2, 3
) select distinct
	bp.header_cid as block,
	bp.parent_header_cid as parent,
	b.miner_id as miner,
	unix_to_height(b.header_timestamp) as height,
	unix_to_height(p.header_timestamp) as parent_height
from block_parents bp
join observed_headers b on bp.header_cid = b.header_cid and bp.miner_id = b.miner_id
join observed_headers p on bp.parent_header_cid = p.header_cid
order by 4 desc`, minHeight, endHeight)
	if err != nil {
		return nil, err
	}
	return models.NewBlockSet(blks), nil
}
