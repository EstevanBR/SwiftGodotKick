.phony: all
all:
	swift build -c release --build-path bin
	@echo "swift-godot-kick is available in bin/release/swift-godot-kick"
