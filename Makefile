.PHONY: lint fmt-check smoke

lint:
	find . -name '*.sh' -print0 | xargs -0 -n1 bash -n
	find . -name '*.sh' -print0 | xargs -0 shellcheck --exclude=SC1090,SC1091

fmt-check:
	shfmt -d .

smoke:
	bash install_security_tools.sh --dry-run all
