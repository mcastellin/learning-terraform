package test

import (
	"fmt"
	"os/exec"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCertGeneration(t *testing.T) {

	cmd := exec.Command("bash", "-c", "aws route53 list-hosted-zones | jq --raw-output '.HostedZones[0].Name'")
	stdout, err := cmd.Output()

	if err != nil {
		require.Nil(t, err, fmt.Sprintf("There was an issue retrieving default hosted-zone from AWS: %s", err.Error()))
	}

	dnsName := string(stdout)
	dnsName = strings.TrimSpace(dnsName)
	require.NotEmpty(t, dnsName, "Testing AWS account must have a valid hosted-zone. Found empty dns_name")

	const subdomain = "jenkins"
	fqdn := fmt.Sprintf("%s.%s", subdomain, strings.TrimRight(dnsName, "."))

	terraformOptions := &terraform.Options{
		TerraformDir: "./acm-certificate",
		Upgrade:      true,

		Vars: map[string]interface{}{
			"dns_name":      dnsName,
			"subdomain":     subdomain,
			"tag_cert_name": "Jenkinstag",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	outDomain := terraform.Output(t, terraformOptions, "cert_domain_name")

	require.Equal(t, fqdn, outDomain)
}

func TestCertGenerationWithoutSubdomain(t *testing.T) {
	cmd := exec.Command("bash", "-c", "aws route53 list-hosted-zones | jq --raw-output '.HostedZones[0].Name'")
	stdout, err := cmd.Output()

	if err != nil {
		require.Nil(t, err, fmt.Sprintf("There was an issue retrieving default hosted-zone from AWS: %s", err.Error()))
	}

	dnsName := string(stdout)
	dnsName = strings.TrimSpace(dnsName)
	require.NotEmpty(t, dnsName, "Testing AWS account must have a valid hosted-zone. Found empty dns_name")

	const subdomain = ""
	fqdn := strings.TrimRight(dnsName, ".")

	terraformOptions := &terraform.Options{
		TerraformDir: "./acm-certificate",
		Upgrade:      true,

		Vars: map[string]interface{}{
			"dns_name":      dnsName,
			"subdomain":     subdomain,
			"tag_cert_name": "Testingtag",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	outDomain := terraform.Output(t, terraformOptions, "cert_domain_name")

	require.Equal(t, fqdn, outDomain)
}
