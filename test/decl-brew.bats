#!/usr/bin/env bats

. test/helpers.sh
. declarations/brew.sh

return_status=0
brew_packages=
brew_outdated=
baked_output=
test_brew () {
  case $1 in
    list) echo "$brew_packages" ;;
    outdated) echo "$brew_outdated" ;;
  esac
  [ -n $return_status ] && return $return_status
}

setup () {
  return_status=0
  bork_setup_brew 'cmd' 'test_brew'
  brew_packages=$(
    echo "current_package"
    echo "outdated_package"
  )
  brew_outdated=$(
    echo "outdated_package (0.5 < 0.6)"
    echo "another_outdated_package (0.4 < 0.4.1)"
  )
  baked_output=$(mktemp -t brewtest)
}

@test "brew status reports a package is missing" {
  run bork_decl_brew status missing_package_is_missing
  [ "$status" -eq 10 ]
}

@test "brew status reports a package is outdated" {
  run bork_decl_brew status outdated_package
  [ "$status" -eq 11 ]
}

@test "brew status reports a packge is current" {
  run bork_decl_brew status current_package
  [ "$status" -eq 0 ]
}

@test "brew install runs 'install'" {
  run bork_decl_brew install missing_package_is_missing
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_brew install missing_package_is_missing' ]
}

@test "brew upgrade runs 'upgrade'" {
  run bork_decl_brew upgrade outdated_package
  [ "$status" -eq 0 ]
  [ "$(baked_output)" = 'test_brew upgrade outdated_package' ]
}
