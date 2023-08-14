package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/drmanalo/charge-events/business/sys/logger"
)

var build = "develop"

func main() {
	log := logger.New(os.Stdout, "CDR-API")

	if err := run(log); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func run(log *logger.Logger) error {
	ctx := context.TODO()

	// -------------------------------------------------------------------------
	// GOMAXPROCS

	log.Info(ctx, "startup", "GOMAXPROCS", runtime.GOMAXPROCS(0), "build", build)

	// -------------------------------------------------------------------------

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)
	<-shutdown

	log.Info(ctx, "shutdown", "status", "shutdown started")
	defer log.Info(ctx, "shutdown", "status", "shutdown complete")

	return nil
}
