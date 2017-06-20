openmips_compile_run:
	@echo "Preparing..."
	@rm -rf .tmp
	@mkdir .tmp
	@echo "Compiling & Running..."
	@iverilog openmips_benchmark.v -o .tmp/openmips.bash
	@vvp -n .tmp/openmips.bash -lxt2 > compiler.txt
	@echo "Remove temporary folder"
	@rm -rf .tmp
