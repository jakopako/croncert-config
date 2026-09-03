---
name: create-venue-scraper-config
description: "Create, tune, validate, and integrate a GoSkyr scraper configuration for a venue website. Use when asked to add a venue scraper, generate a scraper config from a website URL, troubleshoot generated scraping config, or add a scraper to a city's production configuration."
argument-hint: "<website-url> <city>"
---

# Create Venue Scraper Configuration

Create a working GoSkyr scraper for a venue site and integrate it into the repository's production configuration. Treat successful event extraction and a clean targeted dry run as the completion criteria.

## Inputs

Obtain these before beginning when they are not supplied:

- Website URL to scrape.
- Target city name for its configuration under `config/`.
- Venue name, if it cannot be confidently derived from the site.

## Procedure

1. Inspect `generate-config.yaml`.
   - If it does not exist, copy the structure of `generate-config-template.yaml` into a new `generate-config.yaml`.
   - Preserve existing local settings when it already exists; do not overwrite user changes.

2. Generate a starter configuration:

   ```sh
   goskyr generate -u <website-url>
   ```

   Identify the generated configuration and treat it as a starting point, not as production-ready output.
   - When generation fails or needs closer inspection, rerun it with `--debug`:

     ```sh
     goskyr generate -u <website-url> --debug
     ```

     Review the detailed output and the generated HTML artifact. For a dynamic fetcher, also review its screenshot artifact to verify what GoSkyr received and rendered.

3. Validate the generated configuration by running `goskyr scrape` with its generated configuration and `--stdout`, then inspect both command output and extracted events:

   ```sh
   goskyr scrape -c <generated-config-path> -n <generated-scraper-name> --stdout
   ```

   - Success means events are present and relevant, without scraper errors.
   - If event extraction is empty, incomplete, or errors occur, tune `generate-config.yaml` and rerun generation and validation.
   - Start with generator parameters that are likely to explain the failure, especially `min_occurrences` and `fetcher.type` (`static` versus `dynamic`); set `page_load_wait_ms` when a dynamic site needs it.
   - When tuning does not explain the failure, use `goskyr generate --debug` artifacts and the venue HTML/source to identify the actual event-card, title, date, URL, image, and pagination structure.
   - Repeat until validation succeeds or record a concrete blocker, such as authentication, bot protection, unavailable event data, or an unsupported rendering flow.

4. Integrate the validated scraper into the target city file in `config/`.
   - Create `config/<city>.yml` when it does not exist, using a comparable existing city configuration as the layout reference.
   - Follow neighboring scrapers in the target or comparable city file for YAML layout, field names, and static fields.
   - Add the city- and venue-specific static fields required by the production configuration.
   - Replace any URL-derived `name` with a stable camel-case venue scraper name, matching names used by existing venue scrapers.
   - Keep unrelated city configurations unchanged.

5. Run the targeted production dry run:

   ```sh
   goskyr scrape -c config -n <scraper-name> --dry-run
   ```

   This validates the scraped events against the public API. Fix configuration, parsing, naming, or static-field errors revealed by this command, then rerun it. Finish only when the command succeeds and yields credible events for the requested venue.

## Repairing An Existing Scraper

When a known scraper stops extracting events, preserve its base URL and static fields unless the live venue data proves that they are wrong. Diagnose the existing configuration before regenerating it:

1. Run its focused stdout check first:

   ```sh
   goskyr scrape -c config/<city>.yml -n <scraper-name> --stdout
   ```

2. Use the outcome to select the next inspection:
   - `fetched 0 items` without field errors usually means the `item` selector, page rendering, interaction, or a filter no longer matches.
   - Field parsing errors indicate an affected field is required by default. Either correct the selector, set `can_be_empty: true` for genuinely optional data, or remove a stale optional field. Do not keep an empty `comment` or image selector merely because it used to work.
   - Events found in the page but missing from output often means a hidden filter field is empty or its expected value changed. Inspect the filter field's live values before changing the filter.

3. Inspect a small live HTML slice around one real event card. Prefer stable semantic classes and direct relationships over generated IDs, long full-page selector chains, or `nth-child` selectors. Confirm the item boundary contains exactly one event and that title, URL, date, image, and optional text are relative to it.

4. For dynamic fetchers, run a debug scrape when the static HTML and scraper output disagree:

   ```sh
   goskyr --debug scrape -c config/<city>.yml -n <scraper-name> --stdout
   ```

   Review the generated HTML and screenshot in `debug/`. Confirm that configured clicks executed, the rendered DOM still contains event cards, and selectors match that rendered DOM. Remove or reduce stale load-more interactions when the initial rendered page already contains the needed events.

5. Re-run the focused stdout scrape after each small change. Inspect event count, titles, URLs, dates, venue metadata, and filters before running the production dry run.

## Practical Parsing Rules

- A date-only listing still needs a time component when GoSkyr requires complete event times. Use the repository's established default-time pattern, such as `default: "20:00"` with layout `"15:04"`, only when the venue does not publish a time.
- When desktop and mobile card variants duplicate the same date or title, choose one variant inside each item. Parsing both can cause duplicate date-component errors.
- Keep event URLs when the listing provides them. If a venue publishes no per-event links, retain the program page URL rather than inventing one.
- Verify static city, country, location, and source URL against the live venue page. If a repaired scraper exposes that a venue belongs to a different city, move the entire scraper to that city's file and update the city metadata, then validate it from its new file.
- Filter service, cancellation, or non-concert entries using the venue's current labels. Retain legacy exclusions when they remain harmless, and add new case-insensitive exclusions when labels have been renamed.

## Guardrails

- Never replace an existing `generate-config.yaml` without explicit approval.
- Keep generated and production configuration changes narrowly scoped to the requested venue.
- Do not treat a zero-event run as successful unless the site itself demonstrably has no upcoming events.
- Use `--stdout` for iterative extraction checks and `--dry-run` only for the final public-API validation; these flags are mutually exclusive.
- Prefer patterns already established in the target city configuration over inventing new YAML structures.
