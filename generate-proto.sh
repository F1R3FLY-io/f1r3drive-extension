#!/bin/bash

set -e

# Paths (edit as needed)
PROTO_DIR="Protos"
OUT_DIR="TokenFile/Generated/Protos"
PLUGIN_PATH=".build/checkouts/grpc-swift/.build/release/protoc-gen-grpc-swift"

# Ensure the plugin is built
if [ ! -f "$PLUGIN_PATH" ]; then
  echo "Building protoc-gen-grpc-swift plugin..."
  (cd .build/checkouts/grpc-swift && swift build -c release)
fi

# Create output directory if it doesn't exist
mkdir -p "$OUT_DIR"

# Generate Swift and gRPC Swift files for all .proto files in PROTO_DIR
for PROTO_FILE in "$PROTO_DIR"/*.proto; do
  echo "Generating Swift for $PROTO_FILE..."
  protoc \
    --proto_path="$PROTO_DIR" \
    --swift_out="$OUT_DIR" \
    --grpc-swift_opt=UseAccessLevelOnImports=true \
    --grpc-swift_opt=Server=false \
    --grpc-swift_out="$OUT_DIR" \
    "$PROTO_FILE" \
    --plugin=protoc-gen-grpc-swift="$PLUGIN_PATH"
done

echo "✅ Proto generation complete."

sudo ln -s /opt/homebrew/bin/protoc /usr/local/bin/protoc
