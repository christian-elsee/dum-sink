package main

import (
  "testing"
)

func TestMain(t *testing.T) {
  t.Logf("Enter")
  defer t.Logf("Exit")

  main()
}
