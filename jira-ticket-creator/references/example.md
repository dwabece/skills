# Example ticket and AC calibration

Use this for density, tone and level of detail. Do not reuse its content. The project, paths and
numbers below are invented.

## Complete example (Feature, written with --disco)

```
Title: Export a customer's order history to CSV in the seller panel
Type: Feature

TL;DR:
A seller downloads one customer's order history as CSV from the panel. Today support does it by hand from the database, about 40 requests a month. Main risk: generation time for customers with thousands of orders, since the panel endpoints are synchronous.

Delivered value:
The seller gets the history immediately, with no support request. Support gets about 10 hours a month back.

Description:
The customer view in the seller panel gets an "Export orders" button. On click the seller picks a date range (default: last 90 days) and downloads a CSV. One line per order: date, order number, gross amount, currency, status (paid, shipped, returned, cancelled) and item count. The export covers only orders placed with this seller. One file covers at most 12 months.

Business context:
Sellers settle with business customers based on completed orders. Without the export they file support requests and settlements slip by 1-2 days. Requested by customer support in Q3.

Impact:
Seller panel (customer view), orders API, customer support (fewer "send me the order list" requests). Does not touch the customer or admin panels.

Out of scope:
* export to XLSX or PDF (separate ticket if needed),
* bulk export for all of a seller's customers,
* changes to settlements or invoicing.

Acceptance Criteria (ACs):
- [ ] AC1: Given a logged-in seller on their customer's view, When they click "Export orders" and confirm the default range, Then a CSV downloads with the last 90 days of orders and the columns: date, number, gross_amount, currency, status, item_count.
- [ ] AC2: Given the seller picked a range longer than 12 months, When they confirm, Then the export is refused with a message naming the 12-month limit.
- [ ] AC3: Given a customer who also ordered from another seller, When seller A downloads the export, Then the file contains only orders placed with seller A.
- [ ] AC4: Given a customer with 5000 orders in range, When the seller downloads the export, Then the file is ready in under 10 seconds.
- [ ] AC5: Given a customer with no orders in range, When the seller downloads the export, Then a file with only the header row downloads.
- [ ] AC6: The file opens in Excel and Google Sheets without encoding errors (UTF-8 with BOM, comma separator).

Spikes:
* Confirm with support whether the "returned" status splits into partial and full return.

Potential complications:
* Seller panel endpoints are synchronous; large ranges may exceed the gateway timeout (30 s).
* Amounts were recalculated when a shop changed currency; decide whether the export shows the amount at order time or the recalculated one.

Dev Notes:
Discovery snapshot: a41c9e2 on main
Seller orders come from OrderRepository.findBySellerAndCustomer (apps/api/src/orders/order.repository.ts:88), paginated by 50. The invoice export already has a CSV serializer: libs/export/csv-writer.ts (CsvWriter.write). The seller panel renders the customer view in apps/seller-panel/src/pages/CustomerDetails.tsx. apps/api/src/reports is marked deprecated (README in the directory); no new endpoints there. Order integration tests: apps/api/test/orders.e2e.spec.ts, no tests for exports.

Additional remarks:
Support asks for a 90-day default, the usual settlement period.

Suggested approach (advisory, discovery at a41c9e2 on main):
New endpoint in orders, not reports, reusing CsvWriter. Stream the response instead of building the file in memory, to stay under 10 s on large ranges. Enforce the seller filter in the query, not in the panel.

Note to implementer: this section is advisory and non-binding. Verify it against the current code before acting on it. The Acceptance Criteria define done, not this section.
```

Just under 600 words, the upper end.

## The same ticket without --disco

Every section stays. The ones that leaned on discovery shrink to what the user said, with no
path, symbol or number that only the code could supply:

```
Spikes:
* Confirm with support whether the "returned" status splits into partial and full return.
* Identify the module that serves seller order queries and whether it paginates.

Potential complications:
None identified.

Dev Notes:
Discovery not performed, ticket written from interview only.
The user says the invoice export already writes CSV files. Nothing else is known about the code.

Suggested approach (advisory):
Reuse the invoice export's CSV code if it fits (the user's suggestion, unverified).
```

The TL;DR risk then names only what the user raised.

## Acceptance Criteria: bad vs good

Bad: "The export works correctly."
Why: no observable outcome, banned word.
Good: "- [ ] AC1: Given a logged-in seller, When they click 'Export orders', Then a CSV downloads with the columns date, number, gross_amount, currency, status, item_count."

Bad: "The file generates quickly."
Why: no threshold.
Good: "- [ ] AC4: Given a customer with 5000 orders in range, When the seller downloads the export, Then the file is ready in under 10 seconds."

Bad: "Added an order_exports table and a GET /exports endpoint."
Why: describes implementation, not intent; goes stale when the design changes.
Good: "- [ ] AC2: Given the seller picked a range longer than 12 months, When they confirm, Then the export is refused with a message naming the 12-month limit."

Bad: "The export contains only the seller's orders and opens in Excel."
Why: two independent outcomes in one criterion; one can pass while the other fails.
Good: split into two criteria with their own ids (AC3 and AC6 above), one per outcome.

Bad: "The code is tested."
Why: not an outcome of the feature; test coverage belongs in the team's definition of done, not
in the ticket's ACs.
Good: drop it, or if coverage is the point of the ticket (Task), state the target:
"apps/api/test/orders.e2e.spec.ts covers the three export scenarios from the ACs above."

In a Polish ticket the headers, Given/When/Then and ids stay English, the clauses are Polish:

Bad: "Eksport działa poprawnie."
Why: banned word, no observable outcome.
Good: "- [ ] AC2: Given sprzedawca wybrał zakres dłuższy niż 12 miesięcy, When zatwierdza wybór, Then eksport zostaje odrzucony z komunikatem podającym limit 12 miesięcy."
