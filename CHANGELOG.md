# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.0] - 2019-12-25

### Added

- Add default options to EctoJobScheduler.Job

## [0.5.0] - 2019-12-19

### Added

- Allow handle_job/2 to return something other than %Ecto.Multi{} 

## [0.4.1] - 2019-12-17

### Fixed

- Load config from job module when enqueueing job

## [0.4.0] - 2019-11-28

### Added

- Allow additional options to be given to run and schedule functions in job scheduler
- Add test helpers module

## [0.3.0] - 2019-07-10

### Added 
- Accept struct as param in schedule

## [0.2.0] - 2019-07-01

### Added
- Initial version 

[Unreleased]: https://github.com/rai200890/ecto-job-scheduler/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/rai200890/ecto-job-scheduler/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/rai200890/ecto-job-scheduler/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/rai200890/ecto-job-scheduler/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/rai200890/ecto-job-scheduler/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/rai200890/ecto-job-scheduler/releases/tag/v0.2.0