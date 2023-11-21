.PHONY: generate

generate:
	pushd Sources && protoc service.proto darkside.proto compact_formats.proto -I=. \
	--swift_out=Visibility=Public:LightwalletClientLib \
	--grpc-swift_out=Visibility=Public,Client=true,Server=false:LightwalletClientLib && popd
