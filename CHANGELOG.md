# Changelog

All notable changes to this project's source code will be documented in this file. Items under `Unreleased` are upcoming features that will be out in the next version.

## Contributors

Please follow the recommendations outlined at [keepachangelog.com](https://keepachangelog.com). Please use the existing headings and styling as a guide, and add a link for the version diff at the bottom of the file. Also, please update the `Unreleased` link to compare it to the latest release version.

For all changes prior to the inception of this project, see the [Release History](https://github.com/comfy/comfortable-mexican-sofa/releases) of ComfortableMexicanSofa.

## Versions

## [Unreleased]

Changes since the last non-beta release.

_Please add entries here for your pull requests that have not yet been released._

## [3.0.1] - 2024-12-01

### Added

- Added this CHANGELOG
- Added badges to README for CI build, Test Coverage, Gem version, Gem downloads, and last release

## [3.0.0] - 2024-11-30

First release of `comfortable_media_surfer`.  This new gem is a revival of [ComfortableMexicanSofa](https://github.com/comfy/comfortable-mexican-sofa) which had been dormant for nearly 5 years.

### Fixed

- Fixed all broken tests to now pass on Rails 6.x and 7.x
- Rubocop linting

### Added

- Rails 7 compatibility, including many config and code changes.  See the [PR](https://github.com/shakacode/comfortable-media-surfer/pull/1/files) for full details
- Added github actions workflows for CI build and test coverage
- Added CMS tags for navigation: children, siblings, breadcrumbs, with tests
- Added CMS tag for embedded audio, with tests
- Added CMS tag for image, with tests
- Added ability to write CMS snippets in Markdown, with tests

### Changed

- Rebranded ComfortableMexicanSofa as ComfortableMediaSurfer in to publish gem.  All database table names and schema remain unchanged
- Rails 5 compatibility dropped, as it is EOL
  