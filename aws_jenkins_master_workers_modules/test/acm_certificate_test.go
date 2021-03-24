package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCertGeneration(t *testing.T) {

	dnsName := readDnsName(t)
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

	dnsName := readDnsName(t)
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
