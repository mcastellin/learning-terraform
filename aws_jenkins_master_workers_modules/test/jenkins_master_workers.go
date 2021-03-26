package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestJenkinsMasterWorkers(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "./jenkins-master-workers",
		Upgrade:      true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	albName := terraform.Output(t, terraformOptions, "alb_dns_name")

	// verify that the terraform module can start successfully
	require.NotEmpty(t, albName)
}
