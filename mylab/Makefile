all:
	docker build -t lihebi/mylab -f Dockerfile .
old:
	docker build -t lihebi/mylab-base -f Dockerfile.base .
	docker build -t lihebi/mylab-conda -f Dockerfile.conda .
	# docker build -t lihebi/mylab-julia -f Dockerfile.julia .
	# docker build -t lihebi/mylab -f Dockerfile.lite .
nixlab-base:
	docker build -t lihebi/nixlab-base -f Dockerfile.nix .
	# sudo docker tag nixlab-base localhost:5000/nixlab-base
debug:
	docker build -t nixlab2 -f Dockerfile.debug .

mylab:
	docker build -t mylab -f Dockerfile .
