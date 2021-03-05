package main

import (
	"context"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	logging "github.com/ipfs/go-log/v2"
	"github.com/urfave/cli/v2"
	"golang.org/x/xerrors"

	"github.com/filecoin-project/sentinel/util/chainviz"
	"github.com/filecoin-project/sentinel/util/storage"
	"github.com/filecoin-project/sentinel/util/version"
)

var log = logging.Logger("chainviz")

func main() {
	// Set up a context that is canceled when the command is interrupted
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Set up a signal handler to cancel the context
	go func() {
		interrupt := make(chan os.Signal, 1)
		signal.Notify(interrupt, syscall.SIGTERM, syscall.SIGINT)
		select {
		case <-interrupt:
			cancel()
		case <-ctx.Done():
		}
	}()

	if err := logging.SetLogLevel("*", "info"); err != nil {
		log.Fatal(err)
	}

	app := &cli.App{
		Name:      "chainviz",
		Usage:     "Generate chain vizualizations using dot graphs for observed blockchain starting from <minHeight> and includes the following <chainDistance> tipsets",
		UsageText: "chainviz [options] <minHeight> <chainDistance>",
		Version:   version.String(),
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "db",
				EnvVars: []string{"SENTINEL_DB"},
				Value:   "",
				Usage:   "A connection string for the Sentinel postgres database, for example postgres://postgres:password@localhost:5432/postgres",
			},
		},
		Action: func(cctx *cli.Context) error {
			db, err := storage.ConnectDatabase(cctx.Context, cctx.String("db"), "chainviz-"+version.String())
			if err != nil {
				return xerrors.Errorf("setup database: %w", err)
			}
			defer func() {
				if err := db.Close(); err != nil {
					log.Errorw("close database", "error", err)
				}
			}()

			minHeight, err := strconv.ParseUint(cctx.Args().Get(0), 10, 32)
			if err != nil {
				return xerrors.Errorf("parse minHeight: %w", err)
			}
			desiredChainLen, err := strconv.ParseUint(cctx.Args().Get(1), 10, 32)
			if err != nil {
				return xerrors.Errorf("parse chainDistance: %w", err)
			}

			// Read database
			start := time.Now()
			blks, err := chainviz.Query(cctx.Context, db, minHeight, desiredChainLen)
			if err != nil {
				return xerrors.Errorf("query: %w", err)
			}
			log.Debugf("Read database (duration: %s)\n", time.Since(start))

			// Output dot syntax
			start = time.Now()
			defer func() {
				log.Debugf("Write dot ouput (duration: %s)\n", time.Since(start))
			}()

			if _, err = blks.WriteTo(os.Stdout); err != nil {
				return xerrors.Errorf("write: %w", err)
			}
			return nil
		},
	}

	if err := app.RunContext(ctx, os.Args); err != nil {
		log.Fatal(err)
	}
}
