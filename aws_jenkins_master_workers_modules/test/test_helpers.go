package test

import (
	"fmt"
	"os/exec"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func readDnsName(t *testing.T) string {
	cmd := exec.Command("bash", "-c", "aws route53 list-hosted-zones | jq --raw-output '.HostedZones[0].Name'")
	stdout, err := cmd.Output()

	if err != nil {
		require.Nil(t, err, fmt.Sprintf("There was an issue retrieving default hosted-zone from AWS: %s", err.Error()))
	}

	dnsName := string(stdout)
	return strings.TrimSpace(dnsName)
}
