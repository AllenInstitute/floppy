# aind-data-schema navigation map

Bundled at `resources/schema/aind-data-schema/` — referred to below as `$R`.
Commit `18114d7b1d849cef9ccda57f85d90153e08b4eae` (Fri Jul 31 2026), tag
`v2.9.0-1-g18114d7b`, branch `dev`, `__version__ = "2.9.0"`. `.git`, the diagram
app, and CI config are stripped; source, docs, examples, and `schemas/*.json` are
all present.

Dependency pin: `aind-data-schema-models>=6.1.0,<7`, `pydantic>=2.7,<2.12`,
Python `>=3.10,<3.14`. (`uv.lock` in the upstream repo is stale — it records
models `>=5.4.1,<6`. Trust pyproject.)

Per-model `schema_version` values are independent of the package version:
Metadata 2.7.4 · Acquisition 2.5.3 · DataDescription 2.4.1 · Instrument 2.2.7 ·
Procedures 2.2.2 · Processing 2.3.1 · QualityControl 2.4.2 · Subject 2.3.2 ·
Model 2.0.0.

## Routing — go straight to the right layer

| Question shape | Where |
|---|---|
| Does field X exist? What type is it? | `$R/src/aind_data_schema/core/*.py` and `components/*.py` |
| What are the allowed *values* of enum Y? | `$R/docs/source/aind_data_schema_models/*.md` — the models package is an external dependency, its Python source is not here |
| Why is it designed this way? | `$R/docs/base/core/*.md` (hand-written prose) and `$R/docs/source/{general,coordinate_systems,inheritance,validation}.md` |
| Show me working code | `$R/examples/*.py` |
| What does the wire format look like? | `$R/schemas/*.json` (generated JSON Schema) |
| Will this validate? | `$R/src/aind_data_schema/core/metadata.py` validators + `utils/compatibility_check.py` |

**Note on generated docs:** `$R/docs/source/{metadata,subject,acquisition,…}.md`
are generated — prose from `$R/docs/base/core/<name>.md` plus auto-generated model
tables. For explanation prefer `docs/base/core/`; for field tables either works.

## Core models — `$R/src/aind_data_schema/core/`

| File | Classes | Covers |
|---|---|---|
| `metadata.py` | `Metadata`, `create_metadata_json()`, `CORE_FILES`, `REQUIRED_FILE_SETS` | The combined `metadata.nd.json`. **All cross-file validation lives here.** |
| `data_description.py` | `DataDescription`, `Funding` | License, institution, funding, `data_level`, modalities, project, investigators, asset naming |
| `subject.py` | `Subject` | Thin wrapper: `subject_id` + `subject_details` discriminated union |
| `procedures.py` | `Procedures` | Everything done to subject/specimen before acquisition |
| `instrument.py` | `Instrument`, `DEVICES_REQUIRED` | The rig: `components`, `connections`, calibrations, coordinate systems |
| `acquisition.py` | `Acquisition`, `DataStream`, `ExternalDataStream`, `StimulusEpoch`, `Manipulation`, `AcquisitionSubjectDetails`, `PerformanceMetrics`, `CONFIG_REQUIREMENTS`, `SPECIMEN_MODALITIES` | One episode of collection: which devices were active, how configured |
| `processing.py` | `Processing`, `DataProcess`, `ProcessStage`, `ResourceUsage` | Processing provenance, `dependency_graph`, resources |
| `quality_control.py` | `QualityControl`, `QCMetric`, `CurationMetric`, `QCStatus`, `Status`, `Stage` | Metrics + status history + grouping/tag-failure rules |
| `model.py` | `Model`, `ModelTraining`, `ModelPretraining`, `ModelEvaluation` | ML models trained on or applied to assets |

### Required vs optional — the part people get wrong

Every core field on `Metadata` is `Optional[...] = None`. Required-ness is
enforced by **validators, not typing**:

- `CORE_FILES = ["subject","data_description","procedures","instrument","processing","acquisition","quality_control","model"]`
- `REQUIRED_FILE_SETS = {"subject": ["data_description","procedures","instrument","acquisition"], "processing": ["data_description"], "model": ["data_description"]}`
- `validate_required_files` **raises** unless at least one of `subject` / `processing` / `model` is present.
- `validate_expected_files_by_modality` only **warns** for missing set members, and skips the `instrument` warning when all `data_streams` are `ExternalDataStream`.
- The only truly required (`...`) top-level fields are `Metadata.name` and `Metadata.location`.

## Components — `$R/src/aind_data_schema/components/`

| File | Main classes | Domain |
|---|---|---|
| `devices.py` (781 ln) | `Device`, `Detector`/`Camera`, `Laser`, `LightEmittingDiode`, `Lamp`, `Filter`, `Lens`, `Objective`, `MotorizedStage`/`ScanningStage`, `DAQDevice`, `HarpDevice`, `NeuropixelsBasestation`, `OpenEphysAcquisitionBoard`, `Manipulator`, `EphysProbe`/`EphysAssembly`, `FiberProbe`/`FiberPatchCord`/`FiberAssembly`, `CameraAssembly`, `LaserAssembly`, `LightAssembly`, `PatchClampEphysAssembly`, `DigitalMicromirrorDevice`, `PolygonalScanner`, `PockelsCell`, `Disc`/`Wheel`/`Tube`/`Treadmill`/`Arena`, `Monitor`, `Speaker`, `LickSpout`/`LickSpoutAssembly`, `AirPuffDevice`, `Olfactometer`, `MyomatrixArray`, `Microscope`, `Scanner`, `Catheter`, `Computer`, `Enclosure` | Physical hardware inventory |
| `configs.py` (691 ln) | `DeviceConfig`, `DetectorConfig`, `LaserConfig`, `Channel`, `PatchCordConfig`, `SampleChamberConfig`, `Plane`/`CoupledPlane`/`Slap2Plane`, `Image`/`ImageSPIM`/`PlanarImage`/`PlanarImageStack`, `ImagingConfig`, `SamplingStrategy`/`InterleavedStrategy`/`StackStrategy`, `MousePlatformConfig`, `LickSpoutConfig`, `AirPuffConfig`, `SpeakerConfig`, `OlfactometerConfig`, `JoystickConfig`, `ManipulatorConfig`, `ProbeConfig`, `EphysAssemblyConfig`, `FiberAssemblyConfig`, `MRIScan`, `CatheterConfig`, `MISCameraConfig`, `MISModuleConfig` | Per-acquisition device settings — the `Acquisition` side of every device |
| `coordinates.py` (563 ln) | `CoordinateSystem`, `Axis`, `Translation`, `Rotation`, `Scale`, `Affine`, `NonlinearTransform`, `Atlas`, `AtlasCoordinate`, `CoordinateSystemLibrary`, `AtlasLibrary`, `Handedness`, `RotationDirection` | Coordinate systems, transforms, atlases |
| `subjects.py` | `MouseSubject`, `HumanSubject`, `NonHumanPrimateSubject`, `CalibrationObject`, `Housing`, `BreedingInfo`, `LightCycle`, `WellnessReport`, `Sex`, `MatingStatus` | Species-specific subject details |
| `subject_procedures.py` | `Surgery`, `TrainingProtocol`, `WaterRestriction`, `FoodRestriction`, `NonSurgicalInjection`, `GenericSubjectProcedure` | In-vivo procedures on the animal |
| `surgery_procedures.py` | `Craniotomy`, `Headframe`, `ProbeImplant`, `DeviceImplant`, `GroundWireImplant`, `CatheterImplant`, `MyomatrixInsertion`, `Perfusion`, `SampleCollection`, `BrainInjection`, `Anaesthetic`, `GenericSurgeryProcedure`, `CraniotomyType`, `SampleType` | Things done inside a `Surgery` |
| `injection_procedures.py` | `Injection`, `InjectionDynamics`, `ViralMaterial`, `NonViralMaterial`, `TarsVirusIdentifiers`, `VirusPrepType`, `InjectionProfile` | Injections and injected materials |
| `specimen_procedures.py` | `SpecimenProcedure`, `Section`, `PlanarSection`, `Sectioning`, `PlanarSectioning`, `HybridizationChainReaction`, `HCRSeries`, `SectionOrientation` | Ex-vivo tissue prep, staining, sectioning |
| `reagent.py` | `Reagent`, `Fluorophore`, `FluorescentStain`, `FluorescentReagent`, `Solution`, `OligoProbe`, `GeneProbe`, `GeneProbeSet`, `ProteinProbe`, `SmallMoleculeProbe`, `ProbeReagent` | Reagents, probes, stains |
| `measurements.py` | `Calibration`, `VolumeCalibration`, `PowerCalibration`, `CalibrationFit`, `Maintenance`, `CALIBRATIONS` | Calibration and maintenance records |
| `identifiers.py` | `Code`, `Software`, `Container`, `Person`, `DataAsset`, `CombinedData`, `DatabaseIdentifiers`, `ProtocolMixin`, `Database` | People, code, containers, external DB links |
| `stimulus.py` | `OptoStimulation`, `VisualStimulation`, `PhotoStimulation`, `OlfactoryStimulation`, `AuditoryStimulation`, `PulseShape` | Stimulus parameter blocks (mostly `GenericModel` subclasses) |
| `connections.py` | `Connection` (`source_device`, `target_device`) | Device-to-device wiring |
| `geometry.py` | `Rectangle`, `Circle` | Simple shapes |
| `wrappers.py` | `AssetPath` (a `PurePosixPath`) | Path type |

## Controlled vocabularies

`aind_data_schema_models` is an **external pip dependency, not vendored here.**
Its rationale (`$R/docs/source/registries.rst`): registries track external
standards (NCBI taxonomy, ROR, CCF) on a different release cadence.

For enum values read `$R/docs/source/aind_data_schema_models/*.md` — tables of
`Name | Value`. Available: `atlas`, `brain_atlas`, `coordinates`,
`data_name_patterns`, `devices`, `external`, `harp_types`, `licenses`,
`modalities`, `organizations`, `pid_names`, `process_names`, `reagent`,
`registries`, `species`, `specimen_procedure_types`, `stimulus_modality`,
`system_architecture`, `units`.

Example: `data_name_patterns.md` gives `DataLevel`: `DERIVED=derived`,
`RAW=raw`, `SIMULATED=simulated`.

Usage idiom in core code: `Modality.ONE_OF`, `Organization.ONE_OF` (validated
unions), `Modality.ECEPHYS.abbreviation`.

## Structural facts worth knowing cold

**A complete record** is the eight `CORE_FILES` JSONs combined into
`metadata.nd.json` (`Metadata._FILE_EXTENSION = ".nd.json"`).
`Metadata.write_standard_files(dir)` writes each present core file;
`create_metadata_json(name, location, core_jsons, other_identifiers)` builds the
dict tolerantly, falling back to `model_construct` on validation error.

**Cardinality.** One subject per acquisition: `Acquisition.subject_id: str`
(single, required) and `Procedures.subject_id: str`.
`Acquisition.specimen_id: Optional[Union[str, List[str]]]` may be a list —
multiple specimens from *one* subject — and `check_subject_specimen_id` requires
`subject_id` to appear in each specimen id. `specimen_id` is mandatory for
`SPECIMEN_MODALITIES = [Modality.SPIM.abbreviation, Modality.CONFOCAL.abbreviation]`.
`Subject.subject_details` is a single discriminated value, not a list. **This is
the root of known gap #1.**

**`data_level`.** `DataLevel` enum: `raw`, `derived`, `simulated`. Validators:
`subject_id_when_raw` raises if RAW without `subject_id`; `source_data_when_raw`
raises if `source_data` is set on RAW; `build_name` auto-builds `name` from
`subject_id` + `creation_time` when RAW and name is None, then checks
`DataRegex.DATA`. Derived naming:
`<raw asset_name>_<process_label>_YYYY-MM-DD_hh-mm-ss`. Multi-acquisition
analysis: `<project_name>_<process_label>_YYYY-MM-DD_hh-mm-ss`.
`DataDescription.parse_name(name, data_level)` decomposes.

**Coordinate systems.** `Instrument`, `Acquisition`, and `Procedures` each carry
`.coordinate_system` plus a newer `.global_coordinate_system`
(`Instrument.global_coordinate_system` is required). Every transform is paired
with a `coordinate_system_name` that must match the core file's system, enforced
by `recursive_coord_system_check` in `utils/validators.py` via
`DataCoreModel.coordinate_system_validator`. Migration helper
`migrate_deprecated_coordinate_system` copies the deprecated field with a
`DeprecationWarning`. Libraries: `CoordinateSystemLibrary` (e.g. `BREGMA_ARI`)
and `AtlasLibrary`.

**Validation.** Real validation only happens when you build the full `Metadata`
object; `Metadata.validate_core_fields` deliberately downgrades per-core-file
failures to a logged warning + `model_construct`. Cross-file validators in
`core/metadata.py`: `validate_subject_details_if_not_specimen` (in-vivo requires
`Acquisition.subject_details`), `validate_required_files`,
`validate_expected_files_by_modality`, `validate_smartspim_metadata` /
`validate_ecephys_metadata` (SPIM/ECEPHYS `Injection` must have
`injection_materials`), `validate_instrument_acquisition_compatibility`,
`validate_acquisition_active_devices` (every `DataStream.active_devices` name
must exist in `Instrument.get_component_names()` or
`Procedures.get_device_names()`), `validate_acquisition_connections`,
`validate_calibration_object_tags`, `validate_training_protocol_references`
(warning only), `validate_time_constraints`,
`validate_data_description_name_time_consistency`.
Rig-side only: `utils/compatibility_check.py::InstrumentAcquisitionCompatibility`.
Time bounds: `utils/validators.py::TimeValidation` (`BETWEEN`/`AFTER`/`BEFORE`).
Modality-driven completeness: `CONFIG_REQUIREMENTS` (acquisition) and
`DEVICES_REQUIRED` (instrument) — list-of-lists means "one of each group".

**Inheritance / derived assets.** `docs/source/inheritance.md` +
`utils/inheritance.py`. `Metadata.from_metadata(metadata, process_name=...,
location=..., new_processing=..., new_quality_control=..., **dd_kwargs)` applies
the four rules. `DataDescription.from_raw` / `from_derived` /
`from_data_description` are deprecated shims.

**Base plumbing** (`$R/src/aind_data_schema/base.py`): `DataModel` (auto
`object_type` discriminator, `unit_validator`), `DataCoreModel` (`describedBy`,
`schema_version`, `default_filename()`, `write_standard_file()`),
`GenericModel` (`extra="allow"` with `validate_fieldnames`),
`MAX_FILE_SIZE = 500 * 1024`, `DiscriminatedList`/`Discriminated` helpers.

Other utils: `utils/merge.py` (`merge_process_graph`,
`merge_coordinate_systems`), `utils/exceptions.py::OneOfError`,
`utils/schema_version_bump.py`, `utils/schema_tree.py`. `Acquisition.__add__` and
`DataStream.__add__` merge streams (default `overlap_s=120`).

## Docs worth reading in order, for a newcomer

1. `$R/docs/source/index.rst` — entry point, "I want to…" links, which core files a live-subject asset needs
2. `$R/docs/source/example_workflow/example_workflow.md` (+ `.py`, `.xlsx`) — **the best onboarding doc**: how to actually create metadata for an asset
3. `$R/docs/source/general.md` — why a custom schema, why JSON files, meta-decisions
4. `$R/docs/source/coordinate_systems.md` — with a `BREGMA_ARI` worked example
5. `$R/docs/source/inheritance.md` — derived assets
6. `$R/docs/source/validation.md` — short; `InstrumentAcquisitionCompatibility` rules
7. `$R/docs/source/related_standards.md` — relation to NWB, OME-NGFF, BIDS, Croissant, Hugging Face

## Examples — `$R/examples/*.py`

Each is runnable, builds a model and writes JSON.

- **SPIM / light sheet:** `aind_smartspim_instrument.py`, `aibs_smartspim_instrument.py`, `aibs_smartspim_procedures.py`, `exaspim_instrument.py`, `exaspim_acquisition.py`, `exaspim_quality_control.py`
- **Ephys:** `ephys_instrument.py`, `ephys_acquisition.py`, `procedures.py`
- **Fiber photometry:** `fip_ophys_instrument.py`, `fip_ophys_acquisition.py`, `fip_behavior_instrument.py`, `ophys_acquisition.py`, `ophys_procedures.py`
- **2P / multiplane / Bergamo:** `multiplane_ophys_instrument.py`, `multiplane_ophys_acquisition.py`, `bergamo_ophys_acquisition.py`
- **SLAP2:** `slap2_instrument.py`, `slap2_acquisition.py`, `slap2_structure_acquisition.py`
- **BARseq:** `barseq_instrument.py`, `barseq_acquisition.py` — the canonical `ExternalDataStream` example
- **MRI:** `mri_acquisition.py` · **ISI:** `isi_instrument.py`
- **Per-core-file:** `subject.py`, `data_description.py`, `processing.py`, `quality_control.py`, `model.py`, `thermistor_procedures.py`

## JSON schemas — `$R/schemas/*.json`

Nine generated files, one per core model. `metadata_schema.json` is 1.9 MB,
`instrument_schema.json` 1.26 MB. **Generated — never hand-edit.** Generator:
`$R/src/aind_data_schema/utils/json_writer.py::SchemaWriter`, run in CI as
`python -m aind_data_schema.utils.json_writer --output $DIR [--attach-version]`.

## MCP — `resources/schema/aind-data-mcp/`

Commit `c636990a`. A FastMCP server (`mcp = FastMCP("aind_data_mcp")`, entrypoint
`aind_data_mcp.data_access_server:main`) hosted at
`https://metadata-portal.allenneuraldynamics.org/mcp/`, exposing the AIND
metadata MongoDB and biodata-cache to agents. Targets V2 aind-data-schema.

Tools by file:

- `query_tools.py` — `get_records`, `aggregation_retrieval`, `count_records`, `get_summary`, `flatten_records`, `get_project_names`
- `schema_tools.py` — `get_top_level_nodes`, `get_additional_schema_help`, `get_modality_types`, `get_quality_control_example`
- `example_tools.py` — `get_acquisition_example`, `get_data_description_example`, `get_instrument_example`, `get_procedures_example`, `get_subject_example`, `get_processing_example`, `get_model_example`
- `nwb_tools.py` — `identify_nwb_contents_in_code_ocean`, `identify_nwb_contents_with_s3_link`
- `cache_tools.py` — `get_asset_basics`, `get_unique_project_names`, `get_unique_subject_ids`, `get_source_data_table`, `get_raw_to_derived`, `get_qc_metrics`, `get_assets_smartspim`, `get_unique_genotypes`, `get_platform_qc`, `get_assets_exaspim`, `get_assets_fib`, `get_foraging_sessions`, `get_behavior_curriculum`, `get_time_to_qc`

Resources: `resource://aind_api`, `resource://load_nwbfile`,
`resource://cache_tables`, `resource://cache_api`.

Also useful: `scripts/benchmark/questions/questions.json` is an existing Q&A
benchmark set for this schema.
