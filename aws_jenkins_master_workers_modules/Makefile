.PHONY: clean
clean:
	$(call rm-command,test/*/.terraform)
	$(call rm-command,test/*/.terraform.lock.hcl)
	$(call rm-command,test/*/*.tfstate)
	$(call rm-command,test/*/*.tfstate.backup)

.PHONY: clean-root-state
clean-root-state:
	$(call rm-command,.terraform)
	$(call rm-command,*.tfstate)
	$(call rm-command,*.tfstate.backup)

.PHONY: cleanall
cleanall: clean clean-root-state

.PHONY: go-test
go-test:
	$(call go-test)

.PHONY: test
test: go-test clean

.PHONY: fmt
fmt:
	$(call tf-format)


# define helper functions
rm-command = rm -rf ${1}
go-test = cd test/ && go test -v
tf-format = terraform fmt -recursive