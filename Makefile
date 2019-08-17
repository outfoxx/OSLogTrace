

project:=OSLogTrace

clean:
	rm -rf $(project).xcodeproj
	rm -rf Project
	rm -rf TestResults

define buildteston
	xcodebuild -project $(project).xcodeproj -scheme $(project)_$(1) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -destination 'platform=$(1) Simulator,name=$(2)' build test
endef

define buildtest
	xcodebuild -project $(project).xcodeproj -scheme $(project)_$(1) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) build test
endef

build-test-all:	
	xcodegen
	$(call buildtest,macOS)
	$(call buildteston,iOS,iPhone 8)
	$(call buildteston,tvOS,Apple TV)
