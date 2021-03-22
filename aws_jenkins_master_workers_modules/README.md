# Infrastructure as Code Example

TODO list:
- [ ] Review the entire terraform setup and try come up with additional parametrization that we can use to replicate this whole setup multiple times for test/production environments
- [ ] Have terragrunt generate providers in every infrastructure module rather than including it myself
- [ ] The final touch would be to introduce infrastructure automation testing with terratest, so reorganise the project a little to accommodate that. Ideally we want to run the test from a docker container like I've seen here https://github.com/mineiros-io/terraform-aws-route53