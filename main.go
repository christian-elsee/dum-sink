package main

import (
	"os"
	"github.com/christian-elsee/dumb-sink/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
