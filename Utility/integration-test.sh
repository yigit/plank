#!/bin/bash

set -eo pipefail

PLANK_BIN=.build/debug/plank

# build the custom swift package
(cd Examples/MyCustomPackage && swift build)
# Generate Objective-C files
# Filter JSON files: exclude *_decorations.json and base files that have decoration variants
JSON_FILES=()
for file in Examples/PDK/*.json; do
  filename=$(basename "$file")

  # Skip files ending with _decorations.json
  if [[ "$filename" == *_decorations.json ]]; then
    continue
  fi

  # Get base name without .json extension
  basename="${filename%.json}"

  # Check if any decoration files exist for this base file
  if ls Examples/PDK/"${basename}"*decorations.json 1> /dev/null 2>&1; then
    continue
  fi

  JSON_FILES+=("$file")
done

# Generate Objective-C models
$PLANK_BIN --output_dir=Examples/Cocoa/Sources/Objective_C/ "${JSON_FILES[@]}"

# Generate Objective-C models with iOS decorations
for file in Examples/PDK/*.json; do
  filename=$(basename "$file")

  # Get base name without .json extension
  basename="${filename%.json}"

  # Check if iOS decoration file exists
  if [ -f "Examples/PDK/${basename}_ios_decorations.json" ]; then
    $PLANK_BIN --output_dir=Examples/Cocoa/Sources/Objective_C/ \
      --no_runtime \
      --objc_decorations "Examples/PDK/${basename}_ios_decorations.json" \
      "$file"
  fi
done

# Move headers in the right place for the Swift PM
mv Examples/Cocoa/Sources/Objective_C/*.h Examples/Cocoa/Sources/Objective_C/include

# Generate flow types for models
$PLANK_BIN --lang flow  --output_dir=Examples/JS/flow/ "${JSON_FILES[@]}"

# Generate flow types for models
$PLANK_BIN --lang java --java_package_name com.pinterest.models --java_nullability_annotation_type androidx --output_dir=Examples/Java/Sources/ "${JSON_FILES[@]}"

# Generate Java models with Android decorations
for file in Examples/PDK/*.json; do
  filename=$(basename "$file")

  # Get base name without .json extension
  basename="${filename%.json}"

  # Check if Android decoration file exists
  if [ -f "Examples/PDK/${basename}_android_decorations.json" ]; then
    $PLANK_BIN --lang java \
      --java_package_name com.pinterest.models \
      --java_nullability_annotation_type androidx \
      --output_dir=Examples/Java/Sources/ \
      --java_decorations_beta "Examples/PDK/${basename}_android_decorations.json" \
      "$file"
  fi
done

ROOT_DIR="${PWD}"

# Build the ObjC library (macOS only)
if [[ $OSTYPE == darwin* ]]; then
  cd Examples/Cocoa
  swift package clean
  swift build
  swift test
  cd "${ROOT_DIR}"
fi

# Verify flow types
if [ -x "$(command -v flow)" ]; then
  echo "Verify flow types"
  cd Examples/JS/flow
  flow
  cd "${ROOT_DIR}"
fi

if [ -n "${ANDROID_HOME}" ]; then
  bazelisk build //Examples/Java:example --verbose_failures
else
  echo "Skipping Android build, ANDROID_HOME is not set"
fi
