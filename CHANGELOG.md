# Changelog
All notable changes to this project will be documented in this file.

The format is a variant of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) combined with categories from [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Breaking changes should trigger an increment to the major version. Features increment the minor version and fixes or other changes increment the patch number.

<a name="v0.4.0"></a>
## [v0.4.0] - 2020-11-17
### Feat
- **dashboard:** Update main dashboard to match latest schema

### Chore
- **make:** Remove deploy directives

### Dep
- Update to drone@v0.4.0, visor@v0.3.0, lotus@v1.1.3


<a name="v0.3.2"></a>
## [v0.3.2] - 2020-10-19

<a name="v0.3.2-rc1"></a>
## [v0.3.2-rc1] - 2020-10-14

<a name="v0.3.0+butterfly-9.29.0"></a>
## [v0.3.0+butterfly-9.29.0] - 2020-09-30
### Dep
- Update to lotus@be9d23b32


<a name="v0.3.0+ignition-9.28.0"></a>
## [v0.3.0+ignition-9.28.0] - 2020-09-29
### Dep
- Update to lotus@v0.8.0

### Feat
- Add visor to Makefile; CI build ([#149](https://github.com/filecoin-project/sentinel/issues/149))
- Rename Telegraf to Sentinel Drone ([#131](https://github.com/filecoin-project/sentinel/issues/131))
- add jaeger and redis to docker compose
- **dashboard:** Update dashboards for Grafana 7.1 ([#135](https://github.com/filecoin-project/sentinel/issues/135))
- **docs:** Describe the purpose for each table in the schema ([#126](https://github.com/filecoin-project/sentinel/issues/126))
- **telefraf:** change the prometheus->telegraf metrics mapping ([#113](https://github.com/filecoin-project/sentinel/issues/113))


<a name="v0.2.2+spacerace-testnet-8.21.0"></a>
## [v0.2.2+spacerace-testnet-8.21.0] - 2020-09-16
### Feat
- provision grafana datasource and dashboards
- **grafana:** Include grafana renderer in docker-compose.yml

### Dep
- Update to lotus@v0.7.0
- Update to lotus@3697a1af, telegraf@64955570
- Update to lotus@b8bbbf3e, telegraf@cd895c0f

### Docs
- update architecture diagram and intro
- fix link to lotus in README
- add architecture diagram


<a name="v0.2.1+spacerace-testnet-8.21.0"></a>
## [v0.2.1+spacerace-testnet-8.21.0] - 2020-08-28
### Fix
- **build:** typo in Makefile
- **telegraf:** Use lotus_api_token for lotus_peer_id processor

### Dep
- Update to lotus@0185090


<a name="v0.2.0+spacerace-testnet-8.21.0"></a>
## [v0.2.0+spacerace-testnet-8.21.0] - 2020-08-28
### Fix
- **make:** Ignore failure when stopping unstarted services
- **systemd:** Tweak lotus-daemon service memory control
- **telegraf:** Explicitly turn off all types of log rotation in default conf

### Dep
- Update to lotus@80f8f71a, telegraf@c5b1d8aa


<a name="0.2.0+calibration-8.19.1"></a>
## 0.2.0+calibration-8.19.1 - 2020-08-20
### Feat
- Manage new deps with make; Reorg into scripts/
- Add lotus as a submodule dependency; Checked out at interop.16.6.0
- **build:** Make grafana data persis to host; More build cleanup
- **build:** Add example telegraf.conf w inputs/outputs for dev
- **ci:** Github Actions can build Telegraf
- **dashboard:** Add Total Messages per 30min; Add null block alert
- **dashboard:** Add top_miners_by_base_reward dashboard
- **dashboards:** Add Top Miners updated at panel; Add PoSt Total/Failed
- **dashboards:** Add new metrics to Chain dashboard
- **dashboards:** Add sentinel_main and host_perf dashboards
- **docs:** Update README w setup instructions; Added sections
- **lotus:** Updating to latest lotus dependencies
- **metrics:** Include host monitoring with telegraf.conf inputs
- **services:** Add make upgrade-services and documentation
- **telegraf:** Add lotus_peer_id processor to default config
- **telegraf:** Lotus input watches from current tipset; Tweak conf
- **telegraf:** Configurable chain_walk_throttle; Update README
- **telegraf:** Install telegraf as a service (linux only)
- **telegraf:** Telegraf can start with listen multiaddr and token
- **telegraf:** Templatize default configuration
- **telegraf:** Include telegraf as submodule within build target

### Fix
- cp telegraf config to build/ if DNE
- missing '}' in main.json dashboard
- **build:** Clean prior telegraf builds; Systemd control during replace
- **build:** Move grafana data dep to make run; Add make deploy-stag
- **build:** Correct telegraf build deps; Update telegraf to latest
- **ci:** Chainwatch make target changed upstream
- **conf:** Clean default conf; Reorg make directives
- **dashboard:** Update tables to match changes in telegraf lotus plugin
- **docs:** Add MIT and Apache licenses
- **grafana:** Use internal named volume over mount from host
- **telegraf:** Revert merging latest changes which break build
- **telegraf:** Adjust logging defaults
- **telegraf:** update to latest
- **telegraf:** Turn off logrotation in telegraf default config
- **telegraf:** Remove host metric data from default config

### Build
- add .idea/ to .gitignore
- Include docker services for `make run|stop`; Ignore artifacts
- Include telegraf to Makefile build target; Update docs

### Ci
- rm Github Action; add CircleCI

### Dep
- Update to lotus@5c6b99c9
- Update to lotus@b3f27c00)
- Update to lotus@ntwk-calibration-8.13.1
- Update to lotus@43586ed9, telegraf@5e2df0ac
- Update to lotus@ntwk-calibration-7.21.1
- Update lotus/chainwatch to latest

### Deps
- Upgrade lotus to v0.4.1
- Update telegraf and lotus to latest master (4af9a20)

### Docs
- Add README

### Polish
- add "updated at" epoch panel to top-miners ([#32](https://github.com/filecoin-project/sentinel/issues/32))

### Refactor
- stop prometheus from polling lotus_info
- **build:** Breakdown the steps within make run|stop


[v0.4.0]: https://github.com/filecoin-project/sentinel/compare/v0.3.2...v0.4.0
[v0.3.2]: https://github.com/filecoin-project/sentinel/compare/v0.3.2-rc1...v0.3.2
[v0.3.2-rc1]: https://github.com/filecoin-project/sentinel/compare/v0.3.0+butterfly-9.29.0...v0.3.2-rc1
[v0.3.0+butterfly-9.29.0]: https://github.com/filecoin-project/sentinel/compare/v0.3.0+ignition-9.28.0...v0.3.0+butterfly-9.29.0
[v0.3.0+ignition-9.28.0]: https://github.com/filecoin-project/sentinel/compare/v0.2.2+spacerace-testnet-8.21.0...v0.3.0+ignition-9.28.0
[v0.2.2+spacerace-testnet-8.21.0]: https://github.com/filecoin-project/sentinel/compare/v0.2.1+spacerace-testnet-8.21.0...v0.2.2+spacerace-testnet-8.21.0
[v0.2.1+spacerace-testnet-8.21.0]: https://github.com/filecoin-project/sentinel/compare/v0.2.0+spacerace-testnet-8.21.0...v0.2.1+spacerace-testnet-8.21.0
[v0.2.0+spacerace-testnet-8.21.0]: https://github.com/filecoin-project/sentinel/compare/0.2.0+calibration-8.19.1...v0.2.0+spacerace-testnet-8.21.0
