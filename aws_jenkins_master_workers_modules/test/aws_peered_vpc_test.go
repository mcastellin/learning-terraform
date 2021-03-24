package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func TestCreateVPCPeering(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "./aws-peered-vpc",
		Upgrade:      true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	masterSubnets := terraform.OutputList(t, terraformOptions, "master_subnets_list")
	require.Len(t, masterSubnets, 2)
	require.NotEmpty(t, masterSubnets[0])
	require.NotEmpty(t, masterSubnets[1])

	peerSubnets := terraform.OutputList(t, terraformOptions, "peer_subnets_list")
	require.Len(t, peerSubnets, 1)
	require.NotEmpty(t, peerSubnets[0])
}
