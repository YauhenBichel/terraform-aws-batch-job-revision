package tests

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type ContainerProperties struct {
	Image                        string                       `json:"image"`
	ResourceRequirements         []ResourceRequirement        `json:"resourceRequirements"`
	JobRoleArn                   string                       `json:"jobRoleArn"`
	ExecutionRoleArn             string                       `json:"executionRoleArn"`
	FargatePlatformConfiguration FargatePlatformConfiguration `json:"fargatePlatformConfiguration"`
	RuntimePlatform              RuntimePlatform              `json:"runtimePlatform"`
	NetworkConfiguration         NetworkConfiguration         `json:"networkConfiguration"`
	Command                      []string                     `json:"command"`
	Environment                  []EnvVar                     `json:"environment"`
	Secrets                      []Secret                     `json:"secrets"`
}

type ResourceRequirement struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}

type FargatePlatformConfiguration struct {
	PlatformVersion string `json:"platformVersion"`
}

type RuntimePlatform struct {
	OperatingSystemFamily string `json:"operatingSystemFamily"`
	CPUArchitecture       string `json:"cpuArchitecture"`
}

type NetworkConfiguration struct {
	AssignPublicIP string `json:"assignPublicIp"`
}

type EnvVar struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

type Secret struct {
	Name      string `json:"name"`
	ValueFrom string `json:"valueFrom"`
}

func TestTerraformInit(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformBinary: "terraform",
		TerraformDir:    "../",
	}

	terraform.Init(t, terraformOptions)

	// terraform.Init fails the test itself when init errors, so there is
	// nothing left to assert here. assert.True(t, true) could not fail.
}

func TestBatchJobDefinitionBasicConfiguration(t *testing.T) {

	tempDir := t.TempDir()
	planFilePath := filepath.Join(tempDir, "terraform.tfplan")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformBinary: "terraform",
		TerraformDir:    "../",
		PlanFilePath:    planFilePath,
		Vars: map[string]interface{}{
			"env":                      "test",
			"service_domain":           "infra-team",
			"job_definition_name":      "test-job-definition",
			"job_revision_type":        "container",
			"platform_capability":      "FARGATE",
			"image_name":               "nginx:latest",
			"vcpu":                     "0.25",
			"memory":                   "512",
			"execution_role":           "arn:aws:iam::123456789012:role/test-job-role",
			"execution_role_arn":       "arn:aws:iam::123456789012:role/test-execution-role",
			"fargate_platform_version": "1.4.0",
			"fargate_platform_operating_system_family": "LINUX",
			"fargate_platform_cpu_architecture":        "X86_64",
			"assign_public_ip":                         "ENABLED",
			"job_command":                              []string{"echo", "hello world"},
			"execution_timeout":                        3600,
			"retry_attempts":                           3,
			"environment_variables_list":               []map[string]interface{}{},
			"secrets_list":                             []map[string]interface{}{},
			"additional_tags":                          map[string]string{},
			"load_date":                                "",
			"load_date_default_enabled":				false,
		},
	})

	terraform.Init(t, terraformOptions)
	terraform.Plan(t, terraformOptions)

	planStruct := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	jobDef := planStruct.ResourcePlannedValuesMap["aws_batch_job_definition.new_revision"]

	assert.Equal(t, "test-job-definition", jobDef.AttributeValues["name"])
	assert.Equal(t, "container", jobDef.AttributeValues["type"])
	assert.Equal(t, []interface{}{"FARGATE"}, jobDef.AttributeValues["platform_capabilities"])
}
