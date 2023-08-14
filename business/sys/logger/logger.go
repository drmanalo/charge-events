package logger

import (
	"context"
	"fmt"
	"io"
	"path/filepath"
	"runtime"
	"time"

	"github.com/ardanlabs/service/foundation/web"
	"golang.org/x/exp/slog"
)

// Logger represents a logger for logging information
type Logger struct {
	handler slog.Handler
}

// New constructs a new log for application use
func New(w io.Writer, serviceName string) *Logger {
	return new(w, LevelInfo, serviceName)
}

// Info logs at LevelInfo with the given context
func (log *Logger) Info(ctx context.Context, msg string, args ...any) {
	log.write(ctx, LevelInfo, 3, msg, args...)
}

// Infoc logs the information at the specified call stack position
func (log *Logger) Infoc(ctx context.Context, caller int, msg string, args ...any) {
	log.write(ctx, LevelInfo, caller, msg, args...)
}

func (log *Logger) write(ctx context.Context, level Level, caller int, msg string, args ...any) {
	slogLevel := slog.Level(level)

	if !log.handler.Enabled(ctx, slogLevel) {
		return
	}

	var pcs [1]uintptr
	runtime.Callers(caller, pcs[:])

	r := slog.NewRecord(time.Now(), slogLevel, msg, pcs[0])

	args = append(args, "trace_id", web.GetTraceID(ctx))
	r.Add(args...)

	log.handler.Handle(ctx, r)
}

// =============================================================================

func new(w io.Writer, minLevel Level, serviceName string) *Logger {

	// Convert the file name to just the name.ext when this key/value will be logged
	f := func(groups []string, a slog.Attr) slog.Attr {
		if a.Key == slog.SourceKey {
			if source, ok := a.Value.Any().(*slog.Source); ok {
				v := fmt.Sprintf("%s:%d", filepath.Base(source.File), source.Line)
				return slog.Attr{Key: "file", Value: slog.StringValue(v)}
			}
		}

		return a
	}

	// Construct the slog JSON handler for use
	handler := slog.Handler(slog.NewJSONHandler(w, &slog.HandlerOptions{AddSource: true, Level: slog.Level(minLevel), ReplaceAttr: f}))

	// Attributes to add to every log
	attrs := []slog.Attr{
		{Key: "service", Value: slog.StringValue(serviceName)},
	}

	// Add those attributes and capture the final handler
	handler = handler.WithAttrs(attrs)

	return &Logger{
		handler: handler,
	}
}
