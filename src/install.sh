#!/usr/bin/env sh

# Source: https://github.com/cardinal-run/get.cardinal.run

set -e

# Function to compare two major.minor.patch versions
# Returns:
#   0 - If version1 is equal to version2
#   1 - If version1 is older than version2
#   2 - If version1 is newer than version2
version_compare () {
  # Get the two versions as arguments
  local version1=$1
  local version2=$2

  # Split the versions into their major, minor, and patch components
  local major1=${version1%%.*}
  local minor1=${version1#*.}
  minor1=${minor1%%.*}
  local patch1=${version1##*.}

  local major2=${version2%%.*}
  local minor2=${version2#*.}
  minor2=${minor2%%.*}
  local patch2=${version2##*.}

  # Compare major versions
  if [ "$major1" -lt "$major2" ]; then
    return 1
  elif [ "$major1" -gt "$major2" ]; then
    return 2
  else
    # Major versions are the same, compare minor versions
    if [ "$minor1" -lt "$minor2" ]; then
      return 1
    elif [ "$minor1" -gt "$minor2" ]; then
      return 2
    else
      # Minor versions are the same, compare patch versions
      if [ "$patch1" -lt "$patch2" ]; then
        return 1
      elif [ "$patch1" -gt "$patch2" ]; then
        return 2
      else
        # Patch versions are the same
        return 0
      fi
    fi
  fi
}

if [ -f pubspec.yaml ]; then
    # Test if Dart is available
    if ! hash dart 2>/dev/null; then
        echo >&2 "Error: Unable to find dart in your PATH."
        exit 1
    fi

    MIN_DART_VERSION="3.6.0"
    DART_VERSION=$(dart --version | awk '{print $4}')
    set +e
    version_compare "$MIN_DART_VERSION" "$DART_VERSION"
    DART_VERSION_COMPARISON=$?
    set -e
    if [ $DART_VERSION_COMPARISON -eq 2 ]; then
      echo >&2 "Error: Dart version ($DART_VERSION) is older than required ($MIN_DART_VERSION)."
      exit 1
    fi

    echo "Installing the Cardinal SDK..."

    if ! dart pub add "cardinal:{hosted: https://pub.cardinal.run}" >/dev/null; then
      echo >&2 "Error: Failed to install the Cardinal SDK."
      exit 1;
    fi

    echo "
The Cardinal SDK has been added to your project.

We recommend you add the following to your main.dart file:

  1 │ import 'package:cardinal/cardinal.dart';
  2 │
  3 │ void main() {
  4 │   await Cardinal.run(
  5 │     dsn: '<YOUR_DSN_HERE>',
  6 │     integrations: {Cardinal.analytics},
  7 │   );
  8 │
  9 │   ...
 10 │ }
"
else 
    echo >&2 "Error: Unable to find a valid project."
    exit 1
fi

echo "For more information, visit:
https://docs.cardinal.run
"
