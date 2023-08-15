package testgrp

import (
	"context"
	"encoding/json"
	"errors"
	"math/rand"
	"net/http"

	v1 "github.com/drmanalo/charge-events/business/web/v1"
)

func Test(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
	if n := rand.Intn(100); n%2 == 0 {
		return v1.NewRequestError(errors.New("TRUSTED ERROR"), http.StatusTeapot)
	}

	status := struct {
		Status string
	}{
		Status: "OK",
	}

	return json.NewEncoder(w).Encode(status)
}
