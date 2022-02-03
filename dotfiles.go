package main

import (
	"bytes"
	"flag"
	"os"
	"os/exec"

	log "github.com/sirupsen/logrus"
)

func main() {
	deleteFlag := flag.Bool("delete", false, "Deletes the symlinks")

	flag.Parse()

	folders, err := os.ReadDir(".")
	if err != nil {
		log.WithFields(log.Fields{
			"folder": ".",
			"error":  err,
		}).Fatal("Error reading directory")
	}

	for _, dirStat := range folders {
		if dirStat.Name()[0] == '.' || !dirStat.IsDir() {
			continue
		}

		homeDir, err := os.UserHomeDir()
		if err != nil {
			log.WithFields(log.Fields{"error": err}).Fatal("Error getting home directory")
		}

		stowCmd := exec.Command("stow", "--verbose", "--restow", "--target", homeDir, dirStat.Name())

		if *deleteFlag {
			stowCmd.Args = []string{"stow", "-D", "--verbose", "--target", homeDir, dirStat.Name()}
		}

		var out bytes.Buffer
		var out2 bytes.Buffer

		stowCmd.Stdout = &out
		stowCmd.Stderr = &out2

		if err := stowCmd.Run(); err != nil {
			log.WithFields(log.Fields{
				"error":     err,
				"directory": dirStat.Name(),
				"stdout":    string(out.Bytes()),
				"stderr":    string(out2.Bytes()),
			}).Fatal("Error stowing directory")
		}
		log.Info(string(out2.Bytes()))
	}
}
