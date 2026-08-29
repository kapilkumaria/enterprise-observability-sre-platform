# Container Image Release Policy

## Purpose

This policy defines how container-image vulnerability findings are
evaluated before deployment to the enterprise observability platform.

## Blocking Findings

An image must not be deployed when any of the following apply:

- A HIGH or CRITICAL application dependency vulnerability exists.
- A HIGH or CRITICAL operating-system vulnerability has a vendor-fixed
  package version available.
- A secret is detected in the source or image.
- A critical container misconfiguration is detected.
- The image digest differs from the artifact that passed validation.

## Unfixed Upstream Findings

A scanner finding without an available vendor fix cannot be remediated
by rebuilding the same source against the same package repositories.

Such a finding does not pass silently. It requires:

- A written vulnerability exception.
- Confirmation that the selected base image is current.
- Confirmation that no affected package upgrade is available.
- Evaluation of a safer supported base image.
- An exploitability assessment.
- Documented compensating controls.
- A defined review deadline.
- Continuous rescanning.

## Scanner Interpretation

Scanner totals must not be compared without considering:

- Vulnerability data source
- Vendor severity
- Installed package mapping
- Fix availability
- Deferred or rejected vendor fixes
- Operating-system support status

Amazon ECR Basic Scanning is retained as an independent registry-side
control.

Trivy is used as the build-time policy engine because its results
include package status and fixed-version information needed to
distinguish actionable findings from unfixed upstream risk.

## Artifact Integrity

Release images use:

- Immutable Git-based tags
- Immutable ECR tags
- Digest-pinned Kubernetes deployments
- A recorded mapping between Git revision, image tag and image digest

The digest, rather than a mutable human-readable tag, is the deployment
identity.
