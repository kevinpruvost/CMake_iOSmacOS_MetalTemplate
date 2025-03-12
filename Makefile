generate_macos: compile_shaders
	mkdir -p build_macos && \
    cd build_macos && cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=./CMake/ios.toolchain.cmake -DPLATFORM=MAC_ARM64 -DENABLE_ARC=OFF

generate_ios: compile_shaders
	mkdir -p build_ios && \
    cd build_ios && cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=./CMake/ios.toolchain.cmake -DPLATFORM=OS64 -DENABLE_ARC=OFF

compile_shaders:
	xcrun -sdk macosx metal -frecord-sources -gline-tables-only -o Assets/AAPLShaders.metallib Assets/AAPLShaders.metal
	xcrun -sdk iphoneos metal -frecord-sources -gline-tables-only -o Assets/AAPLShaders_ios.metallib Assets/AAPLShaders.metal