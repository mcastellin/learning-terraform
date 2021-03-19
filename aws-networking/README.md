# Infrastructure as Code Example

TODO list:
[ ] The destroy provisioner for nodes is kinda deprecated so we need to find another way of deregistering nodes (like the idea of using systemd)
[ ] Review the entire terraform setup and try come up with additional parametrization that we can use to replicate this whole setup multiple times for test/production environments
[ ] I don't like the fact that I need to hardcode values for the backend, so let's try introduce terragrunt to manage TF backends
[ ] The final touch would be to introduce infrastructure automation testing with terratest, so reorganise the project a little to accommodate that. Ideally we want to run the test from a docker container like I've seen here https://github.com/mineiros-io/terraform-aws-route53