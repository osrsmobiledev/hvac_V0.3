# HVAC maintenance app — durable project brief

Last updated: 2026-10-21

## Purpose of this document

This document preserves the owner's requirements so they do not need to explain the app again in every AI conversation. Read it before asking background questions or proposing implementation work.

For the ongoing tab-by-tab explanation of the first applet, read [VERBRANDINGSATTEST_WORKFLOW.md](VERBRANDINGSATTEST_WORKFLOW.md). It records the old app's behavior, intended changes, and the current discussion point.

It records the product intent, known constraints, and unresolved decisions. It does not select an architecture, certify regulatory compliance, or document completed implementation. External API details and government requirements must be verified against authoritative documentation before implementation.

## Project summary

Build a modern Flutter/Dart application for an independent HVAC technician working in Flanders, Belgium. The app supports boiler maintenance visits, manages customer and boiler records, produces the required official maintenance certificate as a PDF, delivers documents by email, and submits the required structured data to VEKA.

The owner describes the existing app, “Eurosoft - Attest,” as no longer working on recent Android phones. The goal is to replace or modernize that working experience. Access to the original source code, database, export formats, certificate templates, and permission to reuse assets has not been established.

Android is the first priority. iPhone support is required. Additional platforms are welcome when practical, but should not delay or weaken the core mobile experience.

The owner has confirmed a fresh start, rather than continuing previous Flutter code. The owner will test the initial app and intends to rent it to other technicians if it works well. Commercial account separation, licensing, pricing, and hosted-service design are not yet decided.

## Owner and collaboration preferences

- The owner has some technical understanding but is not a developer.
- The intended coding environment is the latest Antigravity desktop app, using Gemini 3.8 Flash with High thinking, as reported by the owner. Exact application version and supported instruction-file behavior remain to be checked.
- AI should implement the code and perform the technical checks available to it. The owner will test the actual app and provide feedback.
- Build collaboratively in small pieces. The owner wants readable Flutter/Dart code, helpful comments, and clear guidance on where to edit behavior or appearance later. Comment non-obvious reasoning and contracts rather than every obvious statement.
- Explain decisions in plain language. Recommend a practical option with reasons rather than requiring the owner to choose unfamiliar libraries without context.
- Repeated attempts have made progress and then failed. Preserving decisions, working behavior, and clear continuation context is an important goal.
- The old Eurosoft - Attest workflow has been explained/inspected and recorded. ROADMAP.md proposes a local-draft first version, followed by more complicated capabilities. The owner has not yet agreed the exact first implementation slice.
- Ask focused questions only for information that is missing or materially affects the next step. Do not ask the owner to repeat requirements already recorded here.

## Primary user and operating context

The primary user is a self-employed boiler maintenance technician. They visit a customer, identify the customer and boiler, record the maintenance information, and complete the required paperwork and reporting.

The product should support repeated visits and multiple boilers associated with a customer or location. A customer, property owner, tenant, service location, and boiler are related concepts that must not automatically be treated as the same record.

## Confirmed product requirements

### Customer, location, and boiler records

- Keep a persistent database of customers, service locations, boilers, and maintenance records.
- Record whether relevant people are property owners or tenants, preserving their relationship to the service location.
- Support more than one boiler for a customer.
- Preserve generated PDFs and their association with the relevant customer, location, boiler, and maintenance visit.
- Provide a useful overview of records so the technician can find customers, equipment, past work, and documents.
- Support database import and export. The intended interchange format and compatibility with existing data remain undecided.

### Address lookup

- Use the public Basisregisters Vlaanderen address lookup API when entering or selecting a customer or boiler service address.
- Capture the official address identifiers required for the later VEKA submission, rather than storing only free-text address labels.
- The owner reports that this API is publicly accessible and can be tested.
- Public API documentation and sample endpoints have been identified. Identifier semantics, the exact address-selection flow, and handling of unmatched or incomplete addresses still require implementation-time verification.
- Clarify which address belongs to the customer and which identifies the actual boiler installation; they may differ.

### Maintenance visit and official PDF

- Let the technician collect the customer, installation, and boiler maintenance information needed for the certificate.
- Generate a PDF that meets the applicable government requirements.
- The owner wants to use the supplied government model instead of Eurosoft's spacious three-page layout. Proposed target: one readable A4 main certificate, with continuation pages for overflow and required measurement attachments as needed. The supplied DOCX reports one page in saved metadata, but rendered/fill-data validation remains outstanding.
- Identify the exact certificate types, official templates, required fields, signatures, calculations, and applicable rules before claiming compliance.
- A generated sample PDF is not evidence that the document has government approval. Compliance or approval must be established using the relevant official requirements and any required validation process.

### Email delivery

- After generating the PDF, send it by email to both the customer and the technician.
- Current owner decision supersedes the earlier acceptance-first sequence: generate the validated PDF and email it to customer and technician without waiting for VEKA acceptance. Queue email while offline. Recipient confirmation and any additional review screen remain to be designed.
- The email provider, sending infrastructure, authentication, and delivery-status handling have not been chosen.

### VEKA reporting

- PDF/email and government reporting are independent workflows. API outage, rejection, or uncertain outcome must not alone block a certificate-ready visit from producing its PDF and email.
- If the API is stuck or unavailable, the technician can report manually through the VEKA portal. Provide an actionable fallback and retain the reporting state until completion is recorded; opening the portal or issuing the PDF is not proof of reporting.
- Record API acceptance/reference or manual reporting actor/date/visit-version and available portal reference/evidence. Distinguish technician-recorded manual reporting from verified API acceptance. Reconcile held, queued, and in-flight automatic attempts before retrying to avoid reporting twice.
- Preserve finalized certificate and submitted payload snapshots and retry PDF, email, and reporting independently. A separate draft-preview feature and corrections/reissue policy remain to be decided.
- The owner changed this product requirement on 2026-10-21. Certificate compliance and reporting obligations still require separate validation; API acceptance is not certification or approval of the PDF, and manual fallback does not establish that a particular certificate is legally valid.
- Submit a separate JSON payload containing the required maintenance information to the government through the VEKA API.
- Include the required official address identifiers obtained through address lookup.
- The app must work offline. Work awaiting government submission should have a visible pending status. Define draft, pending, sending, accepted, and failed states precisely when designing the integration; pending must not imply that VEKA has accepted a submission.
- A submission guide and installation-location guide are supplied under references/official/veka. Subsequent review of official online VEKA documentation established production and secure-test mTLS environments plus a documented public test API requiring no certificate. See VERBRANDINGSATTEST_WORKFLOW.md for links, base URLs, and unresolved specification inconsistencies. Production credentials/certificates and a verified executable schema remain unavailable; no API submission or successful test connection has been performed.
- Do not invent endpoints, credentials, payload fields, or successful submissions. Any demonstration integration must be clearly identified as a simulation.
- The intended transport is an API submission; the exact JSON schema and whether VEKA requires a file or request body must come from its documentation.

### Maintenance reminders and customer responses

- Provide an overview of maintenance that is due so the technician can decide whom to contact and when.
- The technician controls sending maintenance reminder emails based on their real-world availability and workload. Do not automatically send reminders solely because maintenance is due.
- Include a link through which the customer can confirm or decline the proposed maintenance follow-up.
- Notify the technician when a customer needs maintenance and make the customer's response available.
- The technician then contacts the customer and arranges an appointment.
- Do not assume that customer confirmation automatically creates a booked appointment.
- The meaning of confirmation, due-date rules, timing, notification channels, and customer-response website remain to be decided.

## Intended end-to-end journey

1. The technician finds or creates a customer record.
2. They select or create the service location and identify the property owner or tenant as needed.
3. They use address lookup to select the official installation address and preserve the relevant identifiers.
4. They select an existing boiler or add another boiler at that location.
5. They complete the maintenance visit and enter the required measurements and findings.
6. The app validates the certificate information and preserves a finalized visit snapshot. Reporting validation remains separate.
7. The app generates and stores the compliant official-format PDF linked to that finalized visit version without waiting for the VEKA API.
8. The PDF is emailed to the customer and technician, or queued while offline, with delivery outcomes tracked separately.
9. Independently, the required JSON is submitted/queued for VEKA. If automatic reporting fails or is unavailable, the technician can report through the portal and record its completion details. Pending, rejected, and uncertain reporting remains visible until reconciled.
10. The record appears in the technician's overview and supports future maintenance follow-up.
11. The technician reviews due maintenance and chooses when to send reminders; the customer can confirm or decline through a link.
12. The technician sees that follow-up is needed and contacts the customer to arrange an appointment.

The current requirement is finalized PDF → email, with independent API/manual government reporting. It supersedes the earlier acceptance-before-PDF rule. Detailed validation, reporting deadlines, reconciliation, and correction behavior remain to be designed. A single completed flag cannot represent these separate outcomes.

## Proposed reliability requirements to discuss

The following are recommendations inferred from the workflow, rather than decisions already made by the owner:

- Save maintenance drafts so accidental navigation, app restarts, or temporary connectivity loss do not erase a visit.
- Track PDF generation, each email delivery, and VEKA submission separately so a failure in one step is visible and can be retried appropriately.
- Design retries to avoid duplicate government submissions and unnecessary duplicate emails.
- Preserve completed certificate history; define how corrections work before allowing finalized records to be overwritten.
- Make import behavior explicit, validate incoming data, and provide recovery before a restore or replacement changes existing records.
- Define backup, device-loss recovery, and data export separately; an export button alone does not establish a backup strategy.
- Decide how customer information, credentials, and customer-response links will be protected.
- Verify critical user journeys on real target devices as well as using automated technical checks.

## Open decisions — ask incrementally

### Product and existing material

- Confirmed: start fresh. Legacy applet inspection is complete to the recorded limits; agree ROADMAP.md's proposed bare-bones scope before application scaffolding.
- A certificate template is now supplied at references/official/verbrandingsattest/Verbrandingsattest_hvevpk.docx. Its text has been reviewed, but its provenance, current applicability, and rendered layout still need verification. An old app data export has not been supplied.
- Which boiler/fuel types, certificate types, languages, and regional workflows belong in the first release?

### Data and connectivity

- Confirmed: maintenance work must be supported offline, with visible pending submission status. Decide which operations require connectivity and when queued actions may run.
- Confirmed: the owner tests first, with an intention to rent the app to other technicians later. Device counts, business accounts, staff access, and data separation requirements still need definition.
- Should records remain on the device, synchronize through a cloud service, or support both?
- What existing records need migration, and in what formats can they be exported?

### Official integrations

- Official VEKA environment/access documentation is now identified, including a public test API. Obtain any required supplier agreement and production certificates, confirm current schema/enum ambiguities, and verify test behavior before implementing production reporting.
- What constitutes an accepted submission, and how are rejected or corrected submissions handled?
- Which current official requirements govern the PDF and next-maintenance due date?

### Communications and operations

- From which email address should messages be sent?
- Confirmed: reminders require technician control based on availability. Decide whether sending happens immediately on request, can be scheduled explicitly, or can continue after the app closes.
- What exactly does a customer's confirmation or decline mean, and how should the technician be notified?
- Who will operate any required hosted services, and what recurring budget is acceptable?

## Foundation workflow direction

Version 1 foundation drafts use compact persistent AI instructions, a technical decision record, and small implementation steps that can be checked end to end. ARCHITECTURE.md distinguishes confirmed product constraints from proposed technical boundaries and unselected packages. ROADMAP.md contains proposed stages and a current handoff.

AGENTS.md describes how the coding agent should work; this brief describes the product. Current official Antigravity documentation supports a root AGENTS.md. All six Markdown files have now been moved to the workspace root, and their references updated. README.md explains preserving that layout and verifying active instructions in the app workspace.

Proposed implementation loop: understand the next user outcome → define observable acceptance criteria → inspect existing code → implement a bounded change → run appropriate checks → let the owner test the app → record the result and next step.

An owner's successful manual test is valuable feedback. It complements analyzer checks, appropriate automated tests, and integration verification; these responsibilities should not all be transferred to a non-developer.

## Starting a future AI conversation

Suggested opening message:

> Read root AGENTS.md, README.md, ARCHITECTURE.md, and the current handoff in ROADMAP.md. Consult PROJECT_BRIEF.md and relevant workflow sections. Inspect actual code before claiming implementation progress. Ask only questions needed for the next bounded step. We are continuing an offline HVAC maintenance app for an independent technician in Flanders, with Android first and iPhone support required. Generate validated PDFs and email independently of VEKA availability; track API/manual reporting separately. I will trial Gemini 3.8 Flash / High and still have more requirements to explain, so keep refining the foundation as we learn.


## Maintenance of this brief

- Preserve the distinction between owner-confirmed requirements, recommendations, unresolved questions, and implemented behavior.
- Update this document when the owner changes the intended product. Record technical decisions and implementation progress in their designated documents once that structure is agreed.
- Keep unknown integration details explicit until verified. Never convert an assumption into a confirmed fact merely because generated code uses it.
