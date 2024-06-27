package cmd

import (
  "testing"
)

func TestRootCommand(t *testing.T) {
  t.Logf("Enter")
  defer t.Logf("Exit")
  
  err := rootCmd.Execute()
  if err != nil {
    t.Errorf("Failed to execute command :: %s", err)
  }
}
