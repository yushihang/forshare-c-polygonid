#!/bin/bash

set -e

current_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "current_directory:$current_directory"
# enter project directory
parent_directory="$(dirname "$current_directory")"
#echo "$parent_directory"
project_directory="$parent_directory"

makefile_path="$project_directory/Makefile"

output_path="$project_directory/output"

framework_path="$parent_directory/xcframework/Frameworks"


# check project existance
if [ -e "$makefile_path" ]; then
    echo "$makefile_path exists."
else
    echo "Error: $makefile_path NOT found!"
    exit 1
fi

rm -rf "$output_path"
mkdir "$output_path"

cgo_output_path="$project_directory/ios"
rm -rf "$cgo_output_path"

mkdir "$output_path/iPhoneSimulator" >/dev/null 2>&1
mkdir "$output_path/iPhoneOS" >/dev/null 2>&1

output_path_iphone_simulator_x86_64="$output_path/iPhoneSimulator/x86_64"
mkdir "$output_path_iphone_simulator_x86_64" > /dev/null 2>&1

output_path_iphone_simulator_arm64="$output_path/iPhoneSimulator/arm64"
mkdir "$output_path_iphone_simulator_arm64" > /dev/null 2>&1

output_path_iphone_simulator_universal="$output_path/iPhoneSimulator/universal"
mkdir "$output_path_iphone_simulator_universal" > /dev/null 2>&1

output_path_iphoneos_arm64="$output_path/iPhoneOS/arm64"
mkdir "$output_path_iphoneos_arm64" > /dev/null 2>&1

libName="libpolygonid.a"

lib_tuple_array=("ios-simulator-arm64:$output_path_iphone_simulator_arm64" "ios-simulator-x86_64:$output_path_iphone_simulator_x86_64" "ios-arm64:$output_path_iphoneos_arm64")



for lib_tuple in "${lib_tuple_array[@]}"; do
    cd "$parent_directory"
    # 按特殊字符拆分元组
    IFS=':' read -ra elements <<< "$lib_tuple"
    
    # 输出元组的两个部分
    echo "config: ${elements[0]}"
    echo "directory: ${elements[1]}"

    config="${elements[0]}"
    make "$config"
    staticlib="$cgo_output_path/libpolygonid-$config.a"

    if [ -e "$staticlib" ]; then
        echo "$staticlib exists."
    else
        echo "Error: $staticlib NOT found! Build failed"
        exit 1
    fi


    cp "$staticlib" "${elements[1]}/$libName"
    
done

xcframework_name="polygonid"


lipo -create "$output_path_iphone_simulator_x86_64/$libName" "$output_path_iphone_simulator_arm64/$libName" -output "$output_path_iphone_simulator_universal/$libName"
cp "$output_path_iphone_simulator_universal/$libName" "$framework_path/$xcframework_name.xcframework/ios-arm64_x86_64-simulator/$libName"
cp "$output_path_iphoneos_arm64/$libName" "$framework_path/$xcframework_name.xcframework/ios-arm64/$libName"


cp -rf "$cgo_output_path/libpolygonid-ios-arm64.h" "$framework_path/$xcframework_name.xcframework/Headers/libpolygonid-ios.h"

echo "Finished"