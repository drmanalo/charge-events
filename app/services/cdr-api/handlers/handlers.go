package handlers

import (
	"net/http"
	"os"

	"github.com/drmanalo/charge-events/app/services/cdr-api/handlers/checkgrp"
	"github.com/drmanalo/charge-events/app/services/cdr-api/handlers/testgrp"
	"github.com/drmanalo/charge-events/business/sys/logger"
	"github.com/drmanalo/charge-events/business/web/v1/mid"
	"github.com/drmanalo/charge-events/foundation/web"
)

// APIMuxConfig contains all the mandatory systems required by handlers
type APIMuxConfig struct {
	Build    string
	Shutdown chan os.Signal
	Log      *logger.Logger
}

func APIMux(cfg APIMuxConfig) *web.App {
	app := web.NewApp(cfg.Shutdown, mid.Logger(cfg.Log), mid.Panics())

	app.Handle(http.MethodGet, "/test", testgrp.Test)

	cgh := checkgrp.New(cfg.Build, cfg.Log)

	app.Handle(http.MethodGet, "/readiness", cgh.Readiness)
	app.Handle(http.MethodGet, "/liveness", cgh.Liveness)

	return app
}
