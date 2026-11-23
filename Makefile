.PHONY: check lint compile

check: lint compile

lint:
	uvx ruff@0.15.11 check .

compile:
	python3 -m compileall -q gimp_mcp_server.py gimp-mcp-plugin.py run_tests.py tests
