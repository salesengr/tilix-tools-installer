.PHONY: lint fmt-check smoke

lint:
	find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
	find . -name '*.sh' -print0 | xargs -0 shellcheck

fmt-check:
	shfmt -d .

smoke:
	bash install_security_tools.sh --dry-run all
