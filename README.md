<p align="center"><img src="images/hero.svg" alt="TRON" width="720"></p>

# TRON: samples

<p align="center"><b>The samples lane: 5 of 30 Harbor task bundles.</b></p>

<p align="center"><a href="#summary"><img src="https://img.shields.io/badge/bundles-5_of_30-845EF7" alt="bundles: 5 of 30"></a> <a href="#evidence-status"><img src="https://img.shields.io/badge/sealed-0-845EF7" alt="sealed: 0"></a> <a href="#difficulty-tiers"><img src="https://img.shields.io/badge/difficulty-measured-845EF7" alt="difficulty: measured"></a></p>

<p align="center"><sub><a href="#abstract">Abstract</a> | <a href="#summary">Summary</a> | <a href="#difficulty-tiers">Difficulty tiers</a> | <a href="#evidence-status">Evidence status</a> | <a href="#coverage">Coverage</a> | <a href="#dataset-structure">Dataset structure</a> | <a href="#verification-and-quality-assurance">Verification and quality assurance</a> | <a href="#reproduction">Reproduction</a> | <a href="#cite">Cite</a> | <a href="#license">License</a> | <a href="#contact">Contact</a></sub></p>

## Abstract

The curated lane of this corpus: at most 30 Harbor task bundles, every anchor seated first and every other bundle in seal order. Bundles past that ceiling live in `delivery/`.

Each bundle is one Harbor task in a directory named by its content-derived uuid5, so the name doubles as an integrity check. This page is rendered from the resident bundles on every reconcile; a value a bundle does not carry reads `absent`, and the page never fills one in.

## Summary

| Property | Value |
| --- | --- |
| Bundles | 5 of 30 |
| Sealed | 0 of 5 |
| Registrations | unregistered (5) |
| Audit verdicts | none (5) |
| Harbor schema | absent (5) |

## Difficulty tiers

Difficulty is measured by the signed pilot alone and never declared in a bundle, so this page states no tier a bundle claims.

## Evidence status

The verdict is the audit outcome recorded at the sealed digest, and `none` means no verdict has landed for that digest yet. Only an authoring run removes a bundle from this lane, so removal waits for the next one.

| uuid | Verdict | Sealed digest | Stream |
| --- | --- | --- | --- |
| 0a1be4f9-e234-58e6-9c00-5d4f50e95b3a | none | absent | none |
| 227fb08f-ad85-5ec6-a030-c4c71f623001 | none | absent | none |
| 84c3f2b6-ca84-5f07-8119-dae07eff3084 | none | absent | none |
| d6e96910-5aa6-5edc-8bbc-b00e3fa6537d | none | absent | none |
| f41e0601-5e1a-5c54-a9d4-07130cca7f0f | none | absent | none |

## Coverage

No resident bundle declares a keyword.

## Dataset structure

| Bundle | Task | Keywords | Registration | Sealed at | Tier |
| --- | --- | --- | --- | --- | --- |
| [`0a1be4f9-e234-58e6-9c00-5d4f50e95b3a`](0a1be4f9-e234-58e6-9c00-5d4f50e95b3a/) | `default/0a1be4f9-e234-58e6-9c00-5d4f50e95b3a` | absent | unregistered | unsealed | - |
| [`227fb08f-ad85-5ec6-a030-c4c71f623001`](227fb08f-ad85-5ec6-a030-c4c71f623001/) | `default/227fb08f-ad85-5ec6-a030-c4c71f623001` | absent | unregistered | unsealed | - |
| [`84c3f2b6-ca84-5f07-8119-dae07eff3084`](84c3f2b6-ca84-5f07-8119-dae07eff3084/) | `default/84c3f2b6-ca84-5f07-8119-dae07eff3084` | absent | unregistered | unsealed | - |
| [`d6e96910-5aa6-5edc-8bbc-b00e3fa6537d`](d6e96910-5aa6-5edc-8bbc-b00e3fa6537d/) | `default/d6e96910-5aa6-5edc-8bbc-b00e3fa6537d` | absent | unregistered | unsealed | - |
| [`f41e0601-5e1a-5c54-a9d4-07130cca7f0f`](f41e0601-5e1a-5c54-a9d4-07130cca7f0f/) | `default/f41e0601-5e1a-5c54-a9d4-07130cca7f0f` | absent | unregistered | unsealed | - |

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#131a33","primaryTextColor":"#e8ecff","primaryBorderColor":"#845EF7","lineColor":"#22d3ee","fontFamily":"monospace"}}}%%
flowchart LR
    bundle["&lt;uuid&gt;/"]
    bundle --> n0["task.toml<br/>runner manifest"]
    bundle --> n1["instruction.md<br/>objective the agent reads"]
    bundle --> n2["environment/<br/>agent sandbox image"]
    bundle --> n3["tests/<br/>verifier, hidden from the agent"]
    bundle --> n4["solution/<br/>private oracle"]
    bundle --> n5["trajectories/"]
```

```mermaid
%%{init: {"theme":"base","themeVariables":{"primaryColor":"#131a33","primaryTextColor":"#e8ecff","primaryBorderColor":"#845EF7","lineColor":"#22d3ee","fontFamily":"monospace"}}}%%
flowchart LR
    staging["staging/"]
    staging --> samples["samples/<br/>5 of 30"]
    samples --> delivery["delivery/<br/>24 of 10000"]
    delivery --> stock["stock/<br/>0 of 10000"]
```

## Verification and quality assurance

Each bundle's signed provenance carrier holds its screening roots, screening instant, and absolute expiry. Placement moves that carrier into the private derivation set, which this page never reads, so reconcile lists no root it cannot verify here.

## Reproduction

Each bundle directory is a complete Harbor task: `task.toml` is the runner manifest, `instruction.md` the objective, `environment/` the sandbox image, and `tests/` the verifier. Point a Harbor runner at one bundle directory to reproduce it; `solution/` stays private.

## Cite

```bibtex
@misc{tron2026,
  title        = {TRON: A Trainable Enterprise-Operations Environment and Task Suite},
  author       = {{Ethara.AI}},
  year         = {2026},
  note         = {Verifiable cross-system agentic enterprise operations, graded on final database state}
}
```

## License

Released under the MIT License. See [`LICENSE`](LICENSE). Vendored submodules and any datasets or task bundles produced through this project retain their own original licences.

## Contact

The organization is Ethara.AI. Security and benchmark-integrity reports go to the address and process in [`SECURITY.md`](SECURITY.md), privately and never through a public issue. Contribution routes, sign-off gates, and the markdown discipline are in [`CONTRIBUTING.md`](CONTRIBUTING.md). Community standards are in [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
