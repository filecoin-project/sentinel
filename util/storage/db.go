package storage

import (
	"context"
	"errors"

	"github.com/go-pg/pg/v10"
	"golang.org/x/xerrors"
)

// ErrNameTooLong indicates when app name is too long
var ErrNameTooLong = errors.New("name exceeds maximum length for postgres application names")

// MaxPostgresNameLength limits the size of the application name
const MaxPostgresNameLength = 64

// ConnectDatabase accepts a connection url and application name along with a context.Context
// which is respected during connection and ping. A *pg.DB is returned suitable for use
// with chainviz.Query.
func ConnectDatabase(ctx context.Context, url string, name string) (*pg.DB, error) {
	if len(name) > MaxPostgresNameLength {
		return nil, ErrNameTooLong
	}

	opt, err := pg.ParseURL(url)
	if err != nil {
		return nil, xerrors.Errorf("parse database URL: %w", err)
	}
	if opt.ApplicationName == "" {
		opt.ApplicationName = name
	}

	db, err := connect(ctx, opt)
	if err != nil {
		return nil, xerrors.Errorf("connect: %w", err)
	}
	return db, nil
}

func connect(ctx context.Context, opt *pg.Options) (*pg.DB, error) {
	db := pg.Connect(opt)
	db = db.WithContext(ctx)

	// Check if connection credentials are valid and PostgreSQL is up and running.
	if err := db.Ping(ctx); err != nil {
		return nil, xerrors.Errorf("ping database: %w", err)
	}

	return db, nil
}
