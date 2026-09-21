-- 060 — Training: concept labels + the full 75-question bank
--
-- 15 questions per section, 5 per difficulty, walked easiest first. Every
-- option carries its own note, so a student sees why EACH choice is right or
-- wrong — including a student who guessed correctly.
--
-- Generated from a validated source, not hand-typed. Before this file was
-- written, every question was checked for: exactly one correct answer, a
-- "Correct." note on that option and on no other, every math/quantitative
-- answer RECOMPUTED rather than trusted, balanced answer positions (the
-- original bank put the key on B 46% of the time, here no letter exceeds 27%),
-- no positional references like "Sentence B", and the notation conventions
-- from 053/055. The validator was itself proven by planting six known faults.
--
-- SAFE: `training_questions` has no dependents — nothing references it by
-- foreign key and no score reads it — so replacing its rows cannot touch any
-- student's data. (The same DELETE on `questions` would cascade into every
-- student's history, that is why this bank lives in its own table.)
-- The SQL editor runs this as one transaction: if any insert fails, the delete
-- rolls back with it and the pilot stays in place.


-- ── 1. Concept labels ────────────────────────────────────────────────────────
-- Heads each card with the pattern it teaches, e.g. "Analogies — degree", so a
-- student can say "I'm weak at inference" rather than "I'm bad at reading".

ALTER TABLE training_questions ADD COLUMN IF NOT EXISTS concept TEXT;


-- ── 2. Replace the 3-question pilot with the full bank ───────────────────────

DELETE FROM training_questions WHERE exam = 'hspt';

INSERT INTO training_questions
  (id, section, sort_order, concept, prompt, passage, options, correct_index, difficulty, explanation, option_notes)
SELECT md5(v.key)::UUID, v.section::section_type, v.sort_order, v.concept, v.prompt, v.passage,
       v.options, v.correct_index, v.difficulty, v.explanation, v.option_notes
FROM (VALUES
('train-hspt-verbal-01', 'verbal', 1, convert_from(decode('U3lub255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('QUJVTkRBTlQgbW9zdCBuZWFybHkgbWVhbnM6', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJwbGVudGlmdWwiLCAiY29zdGx5IiwgImhpZGRlbiIsICJyZWNlbnQiXQ==', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('QWJ1bmRhbnQgZGVzY3JpYmVzIGhhdmluZyBhIGdyZWF0IGRlYWwgb2Ygc29tZXRoaW5nIOKAlCBtb3JlIHRoYW4gZW5vdWdoLiBUaGluayBvZiBhbiBhYnVuZGFudCBoYXJ2ZXN0OiB0aGUgYmFybnMgYXJlIGZ1bGwuIFRoZSB3b3JkIGlzIGFib3V0IHF1YW50aXR5LCBzbyB0aGUgYW5zd2VyIGhhcyB0byBiZSBhIHF1YW50aXR5IHdvcmQu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBQbGVudGlmdWwgYW5kIGFidW5kYW50IGJvdGggbWVhbiB0aGVyZSBpcyBhIGxhcmdlIHN1cHBseSBvZiBzb21ldGhpbmcuIiwgIkNvc3RseSBpcyBhYm91dCBQUklDRSwgbm90IGFtb3VudC4gU29tZXRoaW5nIGFidW5kYW50IGlzIG9mdGVuIGNoZWFwIHByZWNpc2VseSBiZWNhdXNlIHRoZXJlIGlzIHNvIG11Y2ggb2YgaXQg4oCUIHRoZSBvcHBvc2l0ZSBwdWxsLiIsICJIaWRkZW4gaXMgYWJvdXQgd2hldGhlciB5b3UgY2FuIFNFRSBzb21ldGhpbmcuIEFuIGFidW5kYW50IHRoaW5nIGlzIHVzdWFsbHkgdGhlIGVhc2llc3QgdGhpbmcgdG8gZmluZC4iLCAiUmVjZW50IGlzIGFib3V0IFRJTUUuIEEgaGFydmVzdCBjYW4gYmUgcmVjZW50IGFuZCB0aW55LCBvciBhYnVuZGFudCBhbmQgeWVhcnMgb2xkLiBEaWZmZXJlbnQgbWVhc3VyZSBlbnRpcmVseS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-02', 'verbal', 2, convert_from(decode('QW50b255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('RlJBR0lMRSBpcyB0aGUgb3Bwb3NpdGUgb2Y6', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJkZWxpY2F0ZSIsICJicm9rZW4iLCAic3R1cmR5IiwgInNtYWxsIl0=', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('RnJhZ2lsZSBtZWFucyBlYXNpbHkgYnJva2VuLiBGb3IgYW4gb3Bwb3NpdGUsIGZpcnN0IHB1dCB0aGUgd29yZCBpbiB5b3VyIG93biB3b3JkcywgdGhlbiBmbGlwIGl0OiBlYXNpbHkgYnJva2VuIGJlY29tZXMgaGFyZCB0byBicmVhay4gT25seSB0aGVuIGxvb2sgYXQgdGhlIGNob2ljZXMg4oCUIHRoZSB0ZXN0IG5lYXJseSBhbHdheXMgaW5jbHVkZXMgYSBzeW5vbnltIHRvIGNhdGNoIHJlYWRlcnMgd2hvIGZvcmdldCB0aGV5IHdhbnQgdGhlIG9wcG9zaXRlLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJEZWxpY2F0ZSBpcyBhIFNZTk9OWU0gb2YgZnJhZ2lsZSDigJQgYm90aCBtZWFuIGVhc2lseSBkYW1hZ2VkLiBPcHBvc2l0ZSBxdWVzdGlvbnMgYWxtb3N0IGFsd2F5cyBwbGFudCB0aGUgd29yZCdzIHR3aW4gYXMgYSB0cmFwLiIsICJCcm9rZW4gaXMgd2hhdCBjYW4gaGFwcGVuIHRvIHNvbWV0aGluZyBmcmFnaWxlLCBub3QgaXRzIG9wcG9zaXRlLiBXYXRjaCBmb3IgY2hvaWNlcyB0aGF0IGFyZSBtZXJlbHkgcmVsYXRlZC4iLCAiQ29ycmVjdC4gU3R1cmR5IG1lYW5zIHN0cm9uZyBhbmQgaGFyZCB0byBicmVhayDigJQgZXhhY3RseSB0aGUgcmV2ZXJzZSBvZiBmcmFnaWxlLiIsICJTaXplIGhhcyBub3RoaW5nIHRvIGRvIHdpdGggaXQuIEEgZ2xhc3Mgc2N1bHB0dXJlIGNhbiBiZSBlbm9ybW91cyBhbmQgc3RpbGwgZnJhZ2lsZS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-03', 'verbal', 3, convert_from(decode('QW5hbG9naWVzIOKAlCBwYXJ0IHRvIHdob2xl', 'base64'), 'UTF8'),
 convert_from(decode('UGV0YWwgaXMgdG8gZmxvd2VyIGFzIHBhZ2UgaXMgdG86', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJpbmsiLCAiYm9vayIsICJ3cml0ZXIiLCAibGlicmFyeSJd', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('VHVybiB0aGUgZmlyc3QgcGFpciBpbnRvIGEgc2VudGVuY2U6IGEgcGV0YWwgaXMgb25lIHBhcnQgb2YgYSBmbG93ZXIuIE5vdyBzd2FwIGluIHRoZSBzZWNvbmQgd29yZDogYSBwYWdlIGlzIG9uZSBwYXJ0IG9mIGEgX19fLiBPbmx5IGJvb2sgZml0cyB0aGUgc2FtZSBzZW50ZW5jZS4gQnVpbGRpbmcgdGhlIHNlbnRlbmNlIGZpcnN0IHN0b3BzIHlvdSBmcm9tIHBpY2tpbmcgYSB3b3JkIHRoYXQgaXMgbWVyZWx5IGNvbm5lY3RlZC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJJbmsgaXMgcHJpbnRlZCBPTiBhIHBhZ2Ug4oCUIGl0IGlzIG5vdCB3aGF0IGEgcGFnZSBiZWxvbmdzIHRvLiBJdCBmbGlwcyB0aGUgcmVsYXRpb25zaGlwLiIsICJDb3JyZWN0LiBBIHBldGFsIGlzIG9uZSBwYXJ0IG9mIGEgZmxvd2VyOyBhIHBhZ2UgaXMgb25lIHBhcnQgb2YgYSBib29rLiBTYW1lIHBhcnQtdG8td2hvbGUgbGluay4iLCAiQSB3cml0ZXIgY3JlYXRlcyBhIGJvb2ssIGJ1dCBhIHBhZ2UgaXMgbm90IHBhcnQgb2YgYSB3cml0ZXIuIENyZWF0b3IgaXMgYSBkaWZmZXJlbnQgcmVsYXRpb25zaGlwIGZyb20gd2hvbGUuIiwgIkEgbGlicmFyeSBob2xkcyBib29rcywgc28gaXQgaXMgdHdvIHN0ZXBzIGF3YXkgZnJvbSBhIHBhZ2UuIFRoZSBwYXR0ZXJuIG5lZWRzIHRoZSB0aGluZyBhIHBhZ2UgaXMgZGlyZWN0bHkgcGFydCBvZi4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-04', 'verbal', 4, convert_from(decode('Q2xhc3NpZmljYXRpb24g4oCUIHdoaWNoIGRvZXMgbm90IGJlbG9uZw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hpY2ggd29yZCBkb2VzIE5PVCBiZWxvbmcgd2l0aCB0aGUgb3RoZXJzPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJjYXJyb3QiLCAidHVybmlwIiwgImFwcGxlIiwgInBvdGF0byJd', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('RmluZCBhIHJ1bGUgdGhhdCBmaXRzIHRocmVlIHdvcmRzIGFuZCBicmVha3MgZm9yIGV4YWN0bHkgb25lLiBUaHJlZSBvZiB0aGVzZSBhcmUgZHVnIG91dCBvZiB0aGUgZ3JvdW5kOyBvbmUgaXMgcGlja2VkIGZyb20gYSB0cmVlLiBXaGVuIHlvdSBjYW4gbmFtZSBhIHJ1bGUgdGhhdCBpbmNsdWRlcyB0aHJlZSBhbmQgZXhjbHVkZXMgb25lIOKAlCBhbmQgYSBzZWNvbmQgcnVsZSBhZ3JlZXMg4oCUIHlvdSBjYW4gYmUgY29uZmlkZW50Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDYXJyb3RzIGdyb3cgdW5kZXJncm91bmQsIGxpa2UgdHVybmlwcyBhbmQgcG90YXRvZXMsIHNvIHRoZXkgYmVsb25nIHRvIHRoZSBncm91cC4iLCAiVHVybmlwcyBncm93IHVuZGVyZ3JvdW5kIHRvbyDigJQgcGFydCBvZiB0aGUgZ3JvdXAuIiwgIkNvcnJlY3QuIEFwcGxlcyBncm93IG9uIHRyZWVzIGFib3ZlIHRoZSBncm91bmQ7IHRoZSBvdGhlciB0aHJlZSBncm93IGluIHRoZSBzb2lsLiBUaGV5IGFyZSBhbHNvIHRoZSBvbmx5IGZydWl0IGhlcmUsIHNvIHR3byBkaWZmZXJlbnQgcnVsZXMgcG9pbnQgdG8gdGhlIHNhbWUgYW5zd2VyLiIsICJQb3RhdG9lcyBncm93IHVuZGVyZ3JvdW5kIGFzIHdlbGwsIHNvIHRoZXkgZml0LiBUaGUgc2hhcmVkIHJ1bGUgaXMgd2hlcmUgdGhleSBncm93LCBub3QgdGhlaXIgc2hhcGUgb3IgY29sb3IuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-05', 'verbal', 5, convert_from(decode('TG9naWMg4oCUIHB1dHRpbmcgdGhpbmdzIGluIG9yZGVy', 'base64'), 'UTF8'),
 convert_from(decode('TWFyaWEgaXMgdGFsbGVyIHRoYW4gSm9uLgpKb24gaXMgdGFsbGVyIHRoYW4gTGVlLgpNYXJpYSBpcyB0YWxsZXIgdGhhbiBMZWUuCklmIHRoZSBmaXJzdCB0d28gc3RhdGVtZW50cyBhcmUgdHJ1ZSwgdGhlIHRoaXJkIHN0YXRlbWVudCBpczo=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUcnVlIiwgIkZhbHNlIiwgIlVuY2VydGFpbiIsICJOZWl0aGVyIl0=', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('TGluZSB0aGVtIHVwIHdpdGggdGhlIHRhbGxlc3Qgb24gdGhlIGxlZnQ6IE1hcmlhLCB0aGVuIEpvbiwgdGhlbiBMZWUuIE9uY2UgdGhlIGZpcnN0IHR3byBzdGF0ZW1lbnRzIGFyZSBwbGFjZWQgb24gb25lIGxpbmUsIHlvdSBjYW4gcmVhZCB0aGUgdGhpcmQgc3RyYWlnaHQgb2ZmIGl0LiBPcmRlcmluZyBxdWVzdGlvbnMgYWxtb3N0IGFsd2F5cyBjb21lIGRvd24gdG8gZHJhd2luZyB0aGF0IGxpbmUu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBNYXJpYSBpcyBhYm92ZSBKb24gYW5kIEpvbiBpcyBhYm92ZSBMZWUsIHNvIE1hcmlhIG11c3QgYmUgYWJvdmUgTGVlLiBUaGUgb3JkZXIgcGFzc2VzIHN0cmFpZ2h0IGRvd24gdGhlIGNoYWluLiIsICJGYWxzZSB3b3VsZCBtZWFuIExlZSBpcyBhdCBsZWFzdCBhcyB0YWxsIGFzIE1hcmlhIOKAlCBpbXBvc3NpYmxlIHdoZW4gTWFyaWEgb3V0cmFua3MgSm9uIGFuZCBKb24gb3V0cmFua3MgTGVlLiIsICJVbmNlcnRhaW4gaXMgZm9yIHdoZW4gdGhlIGZhY3RzIGFsbG93IG1vcmUgdGhhbiBvbmUgb3V0Y29tZS4gSGVyZSB0aGUgY2hhaW4gbGVhdmVzIG9ubHkgb25lLCBzbyBub3RoaW5nIGlzIHVuY2VydGFpbi4iLCAiVGhlIHJlYWwgSFNQVCBnaXZlcyBvbmx5IHRocmVlIHZlcmRpY3RzIG9uIHRoZXNlIOKAlCB0cnVlLCBmYWxzZSwgb3IgdW5jZXJ0YWluLiBOZWl0aGVyIGlzIG5ldmVyIHRoZSBhbnN3ZXI7IGl0IGlzIG9ubHkgaGVyZSB0byBmaWxsIHRoZSBmb3VydGggc2xvdC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-06', 'verbal', 6, convert_from(decode('U3lub255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('Q0FORElEIG1vc3QgbmVhcmx5IG1lYW5zOg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJzZWNyZXRpdmUiLCAiZnJhbmsiLCAic3dlZXQiLCAiY2FyZWZ1bCJd', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('Q2FuZGlkIG1lYW5zIGhvbmVzdCBhbmQgc3RyYWlnaHRmb3J3YXJkLiBBIGNhbmRpZCBwaG90byBpcyB0YWtlbiB3aXRob3V0IHBvc2luZyDigJQgaXQgc2hvd3MgdGhpbmdzIGFzIHRoZXkgcmVhbGx5IGFyZS4gV2hlbiBhIHdvcmQgbG9va3MgbGlrZSBvbmUgeW91IGtub3cgKGNhbmRpZCwgY2FuZHkpLCBjaGVjayB0aGF0IHRoZSBNRUFOSU5HIGFjdHVhbGx5IGNvbm5lY3RzIGJlZm9yZSB0cnVzdGluZyB0aGUgcmVzZW1ibGFuY2Uu', 'base64'), 'UTF8'),
 convert_from(decode('WyJTZWNyZXRpdmUgaXMgY2xvc2UgdG8gdGhlIE9QUE9TSVRFIOKAlCBhIGNhbmRpZCBwZXJzb24gaGlkZXMgbm90aGluZy4iLCAiQ29ycmVjdC4gRnJhbmsgYW5kIGNhbmRpZCBib3RoIG1lYW4gaG9uZXN0IGFuZCBkaXJlY3QsIGV2ZW4gd2hlbiB0aGUgdHJ1dGggaXMgdW5jb21mb3J0YWJsZS4iLCAiU3dlZXQgaXMgdGhlIHRyYXAgZm9yIGFueW9uZSB0aGlua2luZyBvZiBjYW5keS4gU2ltaWxhciBzcGVsbGluZywgdW5yZWxhdGVkIG1lYW5pbmcuIiwgIkNhcmVmdWwgZGVzY3JpYmVzIGNhdXRpb24uIEEgY2FuZGlkIHJlbWFyayBpcyBvZnRlbiB0aGUgb3Bwb3NpdGUgb2YgY2FyZWZ1bCDigJQgaXQgc2F5cyB0aGUgYmx1bnQgdGhpbmcuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-07', 'verbal', 7, convert_from(decode('QW5hbG9naWVzIOKAlCB0b29sIGFuZCB3aGF0IGl0IG1lYXN1cmVz', 'base64'), 'UTF8'),
 convert_from(decode('VGhlcm1vbWV0ZXIgaXMgdG8gdGVtcGVyYXR1cmUgYXMgc2NhbGUgaXMgdG86', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJ3ZWlnaHQiLCAia2l0Y2hlbiIsICJudW1iZXIiLCAiaGVhdCJd', 'base64'), 'UTF8')::JSONB, 0, 2,
 convert_from(decode('U2F5IHRoZSByZWxhdGlvbnNoaXAgYWxvdWQ6IGEgdGhlcm1vbWV0ZXIgaXMgdXNlZCB0byBtZWFzdXJlIHRlbXBlcmF0dXJlLiBUaGVuIHRlc3QgaXQ6IGEgc2NhbGUgaXMgdXNlZCB0byBtZWFzdXJlIF9fXy4gV2VpZ2h0IGlzIHRoZSBvbmx5IGZpdC4gQW5hbG9neSB0cmFwcyBvZnRlbiByZXVzZSBhIHdvcmQgZnJvbSB0aGUgZmlyc3QgcGFpciwgbGlrZSBoZWF0IGhlcmUsIHNvIGJlIHdhcnkgb2YgYSBjaG9pY2UgdGhhdCBmZWVscyBmYW1pbGlhciBvbmx5IGJlY2F1c2UgeW91IGp1c3QgcmVhZCBpdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBBIHRoZXJtb21ldGVyIG1lYXN1cmVzIHRlbXBlcmF0dXJlOyBhIHNjYWxlIG1lYXN1cmVzIHdlaWdodC4iLCAiQSBraXRjaGVuIGlzIHdoZXJlIHlvdSBtaWdodCBmaW5kIGEgc2NhbGUuIExvY2F0aW9uIGlzIGEgZGlmZmVyZW50IHJlbGF0aW9uc2hpcCBmcm9tIHdoYXQgaXQgbWVhc3VyZXMuIiwgIkEgc2NhbGUgc2hvd3MgYSBudW1iZXIsIGJ1dCBzbyBkb2VzIGEgdGhlcm1vbWV0ZXIuIFRoZSBwYXR0ZXJuIGFza3MgV0hBVCBpcyBtZWFzdXJlZCwgYW5kIG51bWJlciBpcyB0b28gZ2VuZXJhbC4iLCAiSGVhdCBiZWxvbmdzIHdpdGggdGhlIHRoZXJtb21ldGVyLCBub3QgdGhlIHNjYWxlLiBJdCBib3Jyb3dzIGZyb20gdGhlIGZpcnN0IHBhaXIgdG8gY2F0Y2ggYSBydXNoZWQgcmVhZGVyLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-08', 'verbal', 8, convert_from(decode('QW50b255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('RElMSUdFTlQgaXMgdGhlIG9wcG9zaXRlIG9mOg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJoYXJkd29ya2luZyIsICJjbGV2ZXIiLCAiaG9uZXN0IiwgImxhenkiXQ==', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('RGlsaWdlbnQgZGVzY3JpYmVzIHNvbWVvbmUgd2hvIHdvcmtzIHN0ZWFkaWx5IGFuZCBjYXJlZnVsbHkuIEZsaXAgdGhhdCDigJQgYXZvaWRzIGVmZm9ydCDigJQgYW5kIGxhenkgaXMgdGhlIG1hdGNoLiBOb3RpY2UgdHdvIG90aGVyIGNob2ljZXMgYXJlIGFsc28gcG9zaXRpdmUgdHJhaXRzOiBhbiBvcHBvc2l0ZSBtdXN0IGJlIG9wcG9zaXRlIGluIHRoZSBTQU1FIHF1YWxpdHksIG5vdCBqdXN0IHNvbWV0aGluZyBkaWZmZXJlbnQu', 'base64'), 'UTF8'),
 convert_from(decode('WyJIYXJkd29ya2luZyBpcyBhIFNZTk9OWU0gb2YgZGlsaWdlbnQuIE9uIGFuIG9wcG9zaXRlIHF1ZXN0aW9uLCB0aGUgc3lub255bSBpcyB0aGUgbW9zdCBjb21tb24gdHJhcC4iLCAiQ2xldmVyIGlzIGFib3V0IGludGVsbGlnZW5jZSwgbm90IGVmZm9ydC4gQSBjbGV2ZXIgcGVyc29uIGNhbiBiZSBsYXp5IG9yIGRpbGlnZW50LiIsICJIb25lc3QgaXMgYWJvdXQgdHJ1dGhmdWxuZXNzIOKAlCBhIGRpZmZlcmVudCBxdWFsaXR5IGVudGlyZWx5LiIsICJDb3JyZWN0LiBEaWxpZ2VudCBtZWFucyBwdXR0aW5nIGluIHN0ZWFkeSwgY2FyZWZ1bCBlZmZvcnQ7IGxhenkgbWVhbnMgYXZvaWRpbmcgZWZmb3J0LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-09', 'verbal', 9, convert_from(decode('QW5hbG9naWVzIOKAlCBkZWdyZWU=', 'base64'), 'UTF8'),
 convert_from(decode('V2FybSBpcyB0byBob3QgYXMgY29vbCBpcyB0bzo=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJicmVlenkiLCAiY29sZCIsICJtaWxkIiwgImRhbXAiXQ==', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('VGhpcyBpcyBhIGRlZ3JlZSBhbmFsb2d5OiB0aGUgc2Vjb25kIHdvcmQgaXMgYSBtb3JlIGludGVuc2UgdmVyc2lvbiBvZiB0aGUgZmlyc3QuIFdhcm0gdG8gaG90IHR1cm5zIHRoZSBoZWF0IHVwOyBjb29sIHRvIGNvbGQgdHVybnMgdGhlIGNoaWxsIHVwLiBXaGVuIHR3byB3b3JkcyBkaWZmZXIgb25seSBpbiBzdHJlbmd0aCwgZmluZCB0aGUgY2hvaWNlIHRoYXQgbWFrZXMgdGhlIHNhbWUganVtcCBpbiB0aGUgc2FtZSBkaXJlY3Rpb24u', 'base64'), 'UTF8'),
 convert_from(decode('WyJCcmVlenkgZGVzY3JpYmVzIHdpbmQsIG5vdCBob3cgY29sZCBzb21ldGhpbmcgaXMuIiwgIkNvcnJlY3QuIEhvdCBpcyBhIHN0cm9uZ2VyIHZlcnNpb24gb2Ygd2FybTsgY29sZCBpcyBhIHN0cm9uZ2VyIHZlcnNpb24gb2YgY29vbC4gVGhlIHNhbWUgc3RlcCB1cCBpbiBpbnRlbnNpdHkuIiwgIk1pbGQgaXMgV0VBS0VSIHRoYW4gY29vbCwgbm90IHN0cm9uZ2VyIOKAlCBpdCBtb3ZlcyBpbiB0aGUgd3JvbmcgZGlyZWN0aW9uLiIsICJEYW1wIGlzIGFib3V0IG1vaXN0dXJlLCBhIGRpZmZlcmVudCBzY2FsZSBlbnRpcmVseS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-10', 'verbal', 10, convert_from(decode('TG9naWMg4oCUIHB1dHRpbmcgdGhpbmdzIGluIG9yZGVy', 'base64'), 'UTF8'),
 convert_from(decode('Qm94IEEgd2VpZ2hzIG1vcmUgdGhhbiBCb3ggQi4KQm94IEMgd2VpZ2hzIGxlc3MgdGhhbiBCb3ggQi4KQm94IEMgd2VpZ2hzIG1vcmUgdGhhbiBCb3ggQS4KSWYgdGhlIGZpcnN0IHR3byBzdGF0ZW1lbnRzIGFyZSB0cnVlLCB0aGUgdGhpcmQgc3RhdGVtZW50IGlzOg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUcnVlIiwgIkZhbHNlIiwgIlVuY2VydGFpbiIsICJOZWl0aGVyIl0=', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('UGxhY2UgYWxsIHRocmVlIG9uIG9uZSBsaW5lLCBoZWF2aWVzdCBmaXJzdC4gQSBpcyBoZWF2aWVyIHRoYW4gQjogQSwgQi4gQyBpcyBsaWdodGVyIHRoYW4gQjogQSwgQiwgQy4gVGhlIHRoaXJkIHN0YXRlbWVudCBjbGFpbXMgQyBiZWF0cyBBLCBhbmQgdGhlIGxpbmUgc2hvd3MgdGhlIHJldmVyc2UuIFRpcDogcmV3cml0ZSBhbnkgJ2xlc3MgdGhhbicgc2VudGVuY2Ugc28gZXZlcnkgY29tcGFyaXNvbiBwb2ludHMgdGhlIHNhbWUgZGlyZWN0aW9uIGJlZm9yZSB5b3UgY29tcGFyZS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJUcnVlIHdvdWxkIHB1dCBDIGFib3ZlIEEuIEJ1dCBBIGlzIGhlYXZpZXIgdGhhbiBCLCBhbmQgQiBpcyBoZWF2aWVyIHRoYW4gQywgc28gQyBpcyBhdCB0aGUgYm90dG9tLiIsICJDb3JyZWN0LiBGcm9tIGhlYXZpZXN0IHRvIGxpZ2h0ZXN0IHRoZSBvcmRlciBpcyBBLCB0aGVuIEIsIHRoZW4gQy4gQyBjYW5ub3Qgb3V0d2VpZ2ggQS4iLCAiVW5jZXJ0YWluIGFwcGxpZXMgd2hlbiB0aGUgZmFjdHMgbGVhdmUgcm9vbSBmb3IgZWl0aGVyIGFuc3dlci4gSGVyZSB0aGV5IGZpeCB0aGUgb3JkZXIgY29tcGxldGVseS4iLCAiVGhlIHJlYWwgSFNQVCBnaXZlcyBvbmx5IHRocmVlIHZlcmRpY3RzIG9uIHRoZXNlIOKAlCB0cnVlLCBmYWxzZSwgb3IgdW5jZXJ0YWluLiBOZWl0aGVyIGlzIG5ldmVyIHRoZSBhbnN3ZXI7IGl0IGlzIG9ubHkgaGVyZSB0byBmaWxsIHRoZSBmb3VydGggc2xvdC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-11', 'verbal', 11, convert_from(decode('U3lub255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('RVBIRU1FUkFMIG1vc3QgbmVhcmx5IG1lYW5zOg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJteXN0ZXJpb3VzIiwgImFuY2llbnQiLCAiZmxlZXRpbmciLCAiYmVhdXRpZnVsIl0=', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('RXBoZW1lcmFsIG1lYW5zIGxhc3Rpbmcgb25seSBhIHZlcnkgc2hvcnQgdGltZSDigJQgYSBzb2FwIGJ1YmJsZSwgYSByYWluYm93LCBhIGZhZC4gSWYgeW91IGRvIG5vdCBrbm93IGEgaGFyZCB3b3JkLCB0aGluayBhYm91dCB3aGF0IGl0IHVzdWFsbHkgZGVzY3JpYmVzLiBUaGVuIGJlIGNhcmVmdWw6IGEgY2hvaWNlIHRoYXQgZGVzY3JpYmVzIHRoZSBLSU5EIG9mIHRoaW5nIHRoZSB3b3JkIGlzIHVzZWQgYWJvdXQgaXMgbm90IHRoZSBzYW1lIGFzIHdoYXQgdGhlIHdvcmQgbWVhbnMu', 'base64'), 'UTF8'),
 convert_from(decode('WyJFcGhlbWVyYWwgdGhpbmdzIGNhbiBzZWVtIG15c3RlcmlvdXMsIGJ1dCB0aGUgd29yZCBpcyBhYm91dCBob3cgTE9ORyBzb21ldGhpbmcgbGFzdHMsIG5vdCBob3cgcHV6emxpbmcgaXQgaXMuIiwgIkFuY2llbnQgbWVhbnMgdmVyeSBvbGQg4oCUIGNsb3NlIHRvIHRoZSBvcHBvc2l0ZSBvZiBzb21ldGhpbmcgdGhhdCBiYXJlbHkgbGFzdHMuIiwgIkNvcnJlY3QuIEVwaGVtZXJhbCBtZWFucyBsYXN0aW5nIGEgdmVyeSBzaG9ydCB0aW1lLCBqdXN0IGFzIGZsZWV0aW5nIGRvZXMuIiwgIlRoZSB3b3JkIGlzIG9mdGVuIHVzZWQgYWJvdXQgYmVhdXRpZnVsIHRoaW5ncywgbGlrZSBhIHN1bnNldCwgd2hpY2ggbWFrZXMgdGhpcyB0ZW1wdGluZy4gQnV0IGl0IG1lYW5zIHNob3J0LWxpdmVkLCBub3QgYmVhdXRpZnVsLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-12', 'verbal', 12, convert_from(decode('QW5hbG9naWVzIOKAlCB3b3JkIHBhcnRz', 'base64'), 'UTF8'),
 convert_from(decode('SWxsZWdpYmxlIGlzIHRvIHJlYWQgYXMgaW5hdWRpYmxlIGlzIHRvOg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJzcGVhayIsICJzZWUiLCAid3JpdGUiLCAiaGVhciJd', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('Qm90aCB3b3JkcyBhcmUgYnVpbHQgdGhlIHNhbWUgd2F5OiBpbC0gb3IgaW4tIG1lYW5zIE5PVCwgYW5kIC1pYmxlIG1lYW5zIGFibGUgdG8gYmUuIElsbGVnaWJsZSBpcyBub3QgYWJsZSB0byBiZSByZWFkOyBpbmF1ZGlibGUgaXMgbm90IGFibGUgdG8gYmUgaGVhcmQuIFdoZW4gdGhlIHdvcmRzIGluIGFuIGFuYWxvZ3kgc2hhcmUgYSBwcmVmaXggYW5kIHN1ZmZpeCwgdGFrZSB0aGVtIGFwYXJ0IOKAlCB0aGUgcGF0dGVybiBpcyB1c3VhbGx5IGhpZGluZyBpbiB0aGUgcGllY2VzLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJTcGVha2luZyBQUk9EVUNFUyBzb3VuZCwgYnV0IGluYXVkaWJsZSBpcyBhYm91dCByZWNlaXZpbmcgaXQuIFRoZSBwYXR0ZXJuIGlzIGFib3V0IHdoYXQgY2Fubm90IGJlIGRvbmUgVE8gdGhlIHRoaW5nLiIsICJTZWVpbmcgcGFpcnMgd2l0aCBpbnZpc2libGUsIG5vdCBpbmF1ZGlibGUuIENsb3NlLCBidXQgdGhlIHdyb25nIHNlbnNlLiIsICJXcml0ZSBpcyBib3Jyb3dlZCBmcm9tIHRoZSByZWFkaW5nIHNpZGUgb2YgdGhlIGFuYWxvZ3kuIEl0IG1hdGNoZXMgaWxsZWdpYmxlJ3MgdG9waWMsIG5vdCBpbmF1ZGlibGUncy4iLCAiQ29ycmVjdC4gSWxsZWdpYmxlIHdyaXRpbmcgY2Fubm90IGJlIHJlYWQ7IGFuIGluYXVkaWJsZSBzb3VuZCBjYW5ub3QgYmUgaGVhcmQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-13', 'verbal', 13, convert_from(decode('TG9naWMg4oCUIG92ZXJsYXBwaW5nIGdyb3Vwcw==', 'base64'), 'UTF8'),
 convert_from(decode('QWxsIHZpb2xpbmlzdHMgYXJlIG11c2ljaWFucy4KU29tZSBtdXNpY2lhbnMgYXJlIGNvbXBvc2Vycy4KU29tZSB2aW9saW5pc3RzIGFyZSBjb21wb3NlcnMuCklmIHRoZSBmaXJzdCB0d28gc3RhdGVtZW50cyBhcmUgdHJ1ZSwgdGhlIHRoaXJkIHN0YXRlbWVudCBpczo=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUcnVlIiwgIkZhbHNlIiwgIlVuY2VydGFpbiIsICJOZWl0aGVyIl0=', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('RHJhdyB0d28gY2lyY2xlcy4gVmlvbGluaXN0cyBzaXQgZW50aXJlbHkgaW5zaWRlIG11c2ljaWFucy4gQ29tcG9zZXJzIG92ZXJsYXAgbXVzaWNpYW5zIHNvbWV3aGVyZSDigJQgYnV0IG5vdGhpbmcgdGVsbHMgeW91IHdoZXJlLiBUaGUgb3ZlcmxhcCBjb3VsZCBpbmNsdWRlIHZpb2xpbmlzdHMsIG9yIGl0IGNvdWxkIGxhbmQgZW50aXJlbHkgb24gcGlhbmlzdHMgYW5kIGRydW1tZXJzLiBXaGVuIHRoZSBzdGF0ZW1lbnRzIGFsbG93IHRoZSBjb25jbHVzaW9uIGJ1dCBkbyBub3QgZm9yY2UgaXQsIHRoZSBhbnN3ZXIgaXMgdW5jZXJ0YWluLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJUcnVlIHdvdWxkIHJlcXVpcmUgdGhlIGNvbXBvc2VycyB0byBkZWZpbml0ZWx5IGluY2x1ZGUgc29tZSB2aW9saW5pc3RzLiBOb3RoaW5nIHNheXMgdGhleSBkbyDigJQgdGhlIGNvbXBvc2VycyBjb3VsZCBhbGwgYmUgZHJ1bW1lcnMuIiwgIkZhbHNlIHdvdWxkIHJlcXVpcmUgdGhlIGNvbXBvc2VycyB0byBpbmNsdWRlIE5PIHZpb2xpbmlzdHMuIE5vdGhpbmcgc2F5cyB0aGF0IGVpdGhlci4gVHJ1ZSBhbmQgRmFsc2UgYm90aCBjbGFpbSB0byBrbm93IHNvbWV0aGluZyB0aGUgc3RhdGVtZW50cyBuZXZlciBnaXZlIHlvdS4iLCAiQ29ycmVjdC4gVGhlIGZpcnN0IHR3byBzdGF0ZW1lbnRzIGFsbG93IHRoZSB0aGlyZCBidXQgZG8gbm90IGZvcmNlIGl0LCBhbmQgdGhhdCBnYXAgaXMgZXhhY3RseSB3aGF0IHVuY2VydGFpbiBtZWFucy4iLCAiVGhlIHJlYWwgSFNQVCBnaXZlcyBvbmx5IHRocmVlIHZlcmRpY3RzIG9uIHRoZXNlIOKAlCB0cnVlLCBmYWxzZSwgb3IgdW5jZXJ0YWluLiBOZWl0aGVyIGlzIG5ldmVyIHRoZSBhbnN3ZXI7IGl0IGlzIG9ubHkgaGVyZSB0byBmaWxsIHRoZSBmb3VydGggc2xvdC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-14', 'verbal', 14, convert_from(decode('QW50b255bXM=', 'base64'), 'UTF8'),
 convert_from(decode('VkVSQk9TRSBpcyB0aGUgb3Bwb3NpdGUgb2Y6', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJjb25jaXNlIiwgImxvdWQiLCAidHJ1dGhmdWwiLCAicmFwaWQiXQ==', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('VmVyYm9zZSBjb21lcyBmcm9tIHRoZSBMYXRpbiB2ZXJidW0sIG1lYW5pbmcgd29yZCDigJQgYSB2ZXJib3NlIHBlcnNvbiB1c2VzIHRvbyBtYW55IHdvcmRzLiBUaGUgb3Bwb3NpdGUgbXVzdCBhbHNvIGJlIGFib3V0IHRoZSBOVU1CRVIgb2Ygd29yZHM6IGNvbmNpc2UuIFdoZW4gYSBoYXJkIHdvcmQgY29udGFpbnMgYSByb290IHlvdSByZWNvZ25pemUsIHRoZSByb290IG9mdGVuIHRlbGxzIHlvdSB3aGljaCBxdWFsaXR5IGlzIGJlaW5nIG1lYXN1cmVkLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBWZXJib3NlIG1lYW5zIHVzaW5nIG1vcmUgd29yZHMgdGhhbiBuZWVkZWQ7IGNvbmNpc2UgbWVhbnMgc2F5aW5nIGl0IGluIGFzIGZldyBhcyBwb3NzaWJsZS4iLCAiTG91ZCBpcyBhYm91dCB2b2x1bWUuIEEgdmVyYm9zZSBzcGVha2VyIGNhbiB3aGlzcGVyLiIsICJUcnV0aGZ1bCBpcyBhYm91dCBob25lc3R5LiBXb3JkaW5lc3Mgc2F5cyBub3RoaW5nIGFib3V0IHdoZXRoZXIgdGhlIHdvcmRzIGFyZSB0cnVlLiIsICJSYXBpZCBpcyBhYm91dCBzcGVlZC4gU29tZW9uZSBjYW4gYmUgdmVyYm9zZSBzbG93bHkgb3IgcXVpY2tseS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-verbal-15', 'verbal', 15, convert_from(decode('Q2xhc3NpZmljYXRpb24g4oCUIHdoaWNoIGRvZXMgbm90IGJlbG9uZw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hpY2ggd29yZCBkb2VzIE5PVCBiZWxvbmcgd2l0aCB0aGUgb3RoZXJzPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJyZWpvaWNlIiwgImV4dWx0IiwgImNlbGVicmF0ZSIsICJsYW1lbnQiXQ==', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('VGhyZWUgb2YgdGhlc2UgbWVhbiBzaG93aW5nIGhhcHBpbmVzczsgb25lIG1lYW5zIHNob3dpbmcgZ3JpZWYuIFRoZSB0cmFwIGlzIHRoZSB1bmZhbWlsaWFyIHdvcmQg4oCUIHN0dWRlbnRzIG9mdGVuIHBpY2sgZXh1bHQganVzdCBiZWNhdXNlIHRoZXkgZG8gbm90IGtub3cgaXQuIEJlZm9yZSBjaG9vc2luZyB0aGUgc3RyYW5nZXN0LWxvb2tpbmcgd29yZCwgY2hlY2sgd2hldGhlciB5b3VyIHJ1bGUgYWN0dWFsbHkgZXhjbHVkZXMgaXQu', 'base64'), 'UTF8'),
 convert_from(decode('WyJSZWpvaWNlIG1lYW5zIHRvIGZlZWwgb3Igc2hvdyBncmVhdCBqb3ksIHNvIGl0IGZpdHMgdGhlIGdyb3VwLiIsICJFeHVsdCBtZWFucyB0byBzaG93IHRyaXVtcGhhbnQgam95LiBJdCBpcyB0aGUgbGVhc3QgZmFtaWxpYXIgd29yZCBoZXJlLCB3aGljaCBtYWtlcyBpdCB0ZW1wdGluZyDigJQgYnV0IGl0IGJlbG9uZ3MuIiwgIkNlbGVicmF0ZSBmaXRzOiBpdCBpcyBhIGpveWZ1bCBhY3Rpb24uIiwgIkNvcnJlY3QuIExhbWVudCBtZWFucyB0byBleHByZXNzIHNvcnJvdzsgdGhlIG90aGVyIHRocmVlIGFsbCBleHByZXNzIGpveS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-01', 'quantitative', 1, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgYWRkaW5n', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMywgNiwgOSwgMTIsIC4uLiBXaGF0IG51bWJlciBzaG91bGQgY29tZSBuZXh0Pw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxMyIsICIxNCIsICIxNSIsICIxOCJd', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('RmluZCB0aGUgZ2FwIGJldHdlZW4gbmVpZ2hib3JzOiA2IOKIkiAzID0gMywgOSDiiJIgNiA9IDMsIDEyIOKIkiA5ID0gMy4gV2hlbiBldmVyeSBnYXAgaXMgdGhlIHNhbWUsIGtlZXAgYWRkaW5nIGl0OiAxMiArIDMgPSAxNS4gQWx3YXlzIGNoZWNrIGF0IGxlYXN0IHR3byBnYXBzIGJlZm9yZSB0cnVzdGluZyBhIHBhdHRlcm4u', 'base64'), 'UTF8'),
 convert_from(decode('WyIxMyBhZGRzIG9ubHkgMS4gVGhlIHNlcmllcyBhZGRzIDMgZXZlcnkgdGltZS4iLCAiMTQgYWRkcyAyLiBDaGVjayB0aGUgZ2FwIGJldHdlZW4gZWFjaCBwYWlyIOKAlCBpdCBpcyBhbHdheXMgMy4iLCAiQ29ycmVjdC4gRWFjaCBudW1iZXIgaXMgMyBtb3JlIHRoYW4gdGhlIG9uZSBiZWZvcmU6IDEyICsgMyA9IDE1LiIsICIxOCBhZGRzIDYsIGRvdWJsaW5nIHRoZSBzdGVwLiBUaGUgc3RlcCBuZXZlciBjaGFuZ2VzIGluIHRoaXMgc2VyaWVzLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-02', 'quantitative', 2, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgc3VidHJhY3Rpbmc=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMjAsIDE3LCAxNCwgMTEsIC4uLiBXaGF0IG51bWJlciBzaG91bGQgY29tZSBuZXh0Pw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyI4IiwgIjkiLCAiNyIsICIxMCJd', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('VGhlIG51bWJlcnMgZ28gZG93biwgc28gZmluZCBob3cgbXVjaCB0aGV5IGRyb3A6IDIwIOKIkiAxNyA9IDMsIDE3IOKIkiAxNCA9IDMsIDE0IOKIkiAxMSA9IDMuIEtlZXAgc3VidHJhY3RpbmcgMzogMTEg4oiSIDMgPSA4LiBBIGZhbGxpbmcgc2VyaWVzIHdvcmtzIGV4YWN0bHkgbGlrZSBhIHJpc2luZyBvbmUg4oCUIHlvdSBqdXN0IHN1YnRyYWN0IHRoZSBnYXAu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBFYWNoIG51bWJlciBpcyAzIGxlc3MgdGhhbiB0aGUgb25lIGJlZm9yZTogMTEg4oiSIDMgPSA4LiIsICI5IHN1YnRyYWN0cyBvbmx5IDIuIFRoZSBzZXJpZXMgZHJvcHMgYnkgMyBlYWNoIHRpbWUuIiwgIjcgc3VidHJhY3RzIDQg4oCUIG9uZSBtb3JlIHRoYW4gdGhlIHJlYWwgc3RlcC4iLCAiMTAgc3VidHJhY3RzIGp1c3QgMS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-03', 'quantitative', 3, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgbXVsdGlwbHlpbmc=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMiwgNCwgOCwgMTYsIC4uLiBXaGF0IG51bWJlciBzaG91bGQgY29tZSBuZXh0Pw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxOCIsICIyMCIsICIyNCIsICIzMiJd', 'base64'), 'UTF8')::JSONB, 3, 1,
 convert_from(decode('VGhlIGdhcHMgYXJlIDIsIDQsIDgg4oCUIG5vdCBjb25zdGFudCwgc28gdGhpcyBpcyBub3QgYW4gYWRkaW5nIHNlcmllcy4gVHJ5IGRpdmlkaW5nIGluc3RlYWQ6IDQgw7cgMiA9IDIsIDggw7cgNCA9IDIsIDE2IMO3IDggPSAyLiBFYWNoIHRlcm0gaXMgZG91YmxlIHRoZSBsYXN0LCBzbyAxNiDDlyAyID0gMzIuIFdoZW4gdGhlIGdhcHMgZ3JvdyBmYXN0LCB0ZXN0IG11bHRpcGxpY2F0aW9uLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyIxOCBhZGRzIDIuIEJ1dCB0aGUgZ2FwcyBoZXJlIGtlZXAgZ3Jvd2luZyDigJQgMiwgNCwgOCDigJQgc28gYWRkaW5nIGEgZml4ZWQgYW1vdW50IGNhbm5vdCB3b3JrLiIsICIyMCBhZGRzIDQsIHJlcGVhdGluZyBhbiBlYXJsaWVyIGdhcC4gVGhlIGdhcHMgZG91YmxlIGVhY2ggdGltZSwgc28gdGhlIG5leHQgb25lIGlzIDE2LiIsICIyNCBhZGRzIDgsIHJlcGVhdGluZyB0aGUgcHJldmlvdXMgZ2FwLiBUaGUgZ2FwcyB0aGVtc2VsdmVzIGFyZSBncm93aW5nLiIsICJDb3JyZWN0LiBFYWNoIG51bWJlciBpcyB0d2ljZSB0aGUgb25lIGJlZm9yZTogMTYgw5cgMiA9IDMyLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-04', 'quantitative', 4, convert_from(decode('TnVtYmVyIG1hbmlwdWxhdGlvbg==', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBudW1iZXIgaXMgNCBsZXNzIHRoYW4gMyDDlyA1Pw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIzIiwgIjExIiwgIjE5IiwgIjE1Il0=', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('V29yayBmcm9tIHRoZSBpbnNpZGUgb3V0LiBUaGUgcGhyYXNlICc0IGxlc3MgdGhhbiAzIMOXIDUnIGlzIGJ1aWx0IG9uIDMgw5cgNSwgc28gZmluZCB0aGF0IGZpcnN0OiAxNS4gVGhlbiAnNCBsZXNzIHRoYW4nIG1lYW5zIHN1YnRyYWN0IDQ6IDExLiBUaGUgd29yZHMgJ2xlc3MgdGhhbicgdGVsbCB5b3UgdG8gdGFrZSBhd2F5IGZyb20gdGhlIG51bWJlciB0aGF0IGNvbWVzIGFmdGVyIHRoZW0u', 'base64'), 'UTF8'),
 convert_from(decode('WyIzIGNvbWVzIGZyb20gc3VidHJhY3RpbmcgZmlyc3Q6IDMgw5cgKDUg4oiSIDQpLiBCdXQgJzQgbGVzcyB0aGFuIDMgw5cgNScgbWVhbnMgZmluZCAzIMOXIDUgYmVmb3JlIGFueXRoaW5nIGVsc2UuIiwgIkNvcnJlY3QuIDMgw5cgNSA9IDE1LCBhbmQgNCBsZXNzIHRoYW4gMTUgaXMgMTEuIiwgIjE5IGFkZHMgNCBpbnN0ZWFkIG9mIHN1YnRyYWN0aW5nIGl0LiAnTGVzcyB0aGFuJyBtZWFucyB0YWtlIGF3YXkuIiwgIjE1IGlzIDMgw5cgNSDigJQgdGhlIHJpZ2h0IHN0YXJ0aW5nIHBvaW50LCBidXQgeW91IHN0aWxsIG5lZWQgdG8gdGFrZSBhd2F5IDQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-05', 'quantitative', 5, convert_from(decode('Q29tcGFyaXNvbnMg4oCUIGFyZSB0aGV5IGVxdWFsPw==', 'base64'), 'UTF8'),
 convert_from(decode('RXhhbWluZSAoYSksIChiKSwgYW5kIChjKSBhbmQgZmluZCB0aGUgYmVzdCBhbnN3ZXIuCihhKSAxLzIgb2YgMTAKKGIpIDUKKGMpIDEwIMO3IDI=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIoYSkgaXMgZ3JlYXRlciB0aGFuIChiKSIsICIoYSksIChiKSwgYW5kIChjKSBhcmUgZXF1YWwiLCAiKGMpIGlzIGdyZWF0ZXIgdGhhbiAoYSkiLCAiKGIpIGlzIGxlc3MgdGhhbiAoYykiXQ==', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('VHVybiBldmVyeSBpdGVtIGludG8gYSBwbGFpbiBudW1iZXIgYmVmb3JlIGNvbXBhcmluZzogKGEpIGhhbGYgb2YgMTAgaXMgNSwgKGIpIGlzIDUsIChjKSAxMCDDtyAyIGlzIDUuIE9ubHkgdGhlbiByZWFkIHRoZSBjaG9pY2VzLiBDb21wYXJpc29uIHF1ZXN0aW9ucyBsb29rIGNvbXBsaWNhdGVkIGJ1dCByZXdhcmQgb25lIGhhYml0OiBjb21wdXRlIGV2ZXJ5dGhpbmcgZmlyc3QsIGNvbXBhcmUgc2Vjb25kLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJIYWxmIG9mIDEwIGlzIDUsIHRoZSBzYW1lIGFzIChiKS4gTmVpdGhlciBpcyBncmVhdGVyLiIsICJDb3JyZWN0LiBIYWxmIG9mIDEwIGlzIDUsIChiKSBpcyA1LCBhbmQgMTAgw7cgMiBpcyA1LiBBbGwgdGhyZWUgYXJlIHRoZSBzYW1lIHZhbHVlLiIsICIxMCDDtyAyIGFuZCBoYWxmIG9mIDEwIGFyZSB0d28gd2F5cyBvZiB3cml0aW5nIHRoZSBzYW1lIHRoaW5nIOKAlCBib3RoIGVxdWFsIDUuIiwgIihiKSBpcyA1IGFuZCAoYykgaXMgNSwgc28gbmVpdGhlciBpcyBsZXNzLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-06', 'quantitative', 6, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgc3F1YXJlIG51bWJlcnM=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMSwgNCwgOSwgMTYsIDI1LCAuLi4gV2hhdCBudW1iZXIgc2hvdWxkIGNvbWUgbmV4dD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIzMCIsICIzNCIsICIzNiIsICI0OSJd', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('VGhlIGdhcHMgYXJlIDMsIDUsIDcsIDkg4oCUIGdyb3dpbmcgYnkgMiBlYWNoIHN0ZXAg4oCUIHNvIHRoZSBuZXh0IGdhcCBpcyAxMTogMjUgKyAxMSA9IDM2LiBPciBzcG90IHRoZSBzaG9ydGN1dDogZWFjaCB0ZXJtIGlzIGEgbnVtYmVyIHRpbWVzIGl0c2VsZiwgMcKyLCAywrIsIDPCsiwgNMKyLCA1wrIsIHNvIHRoZSBzaXh0aCBpcyA2wrIgPSAzNi4gUmVjb2duaXppbmcgc3F1YXJlIG51bWJlcnMgb24gc2lnaHQgc2F2ZXMgcmVhbCB0aW1lLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyIzMCBhZGRzIDUsIGJ1dCB0aGUgZ2FwcyBhcmUgZ3Jvd2luZzogMywgNSwgNywgOS4gVGhlIG5leHQgZ2FwIGlzIDExLiIsICIzNCBhZGRzIDksIHJlcGVhdGluZyB0aGUgbGFzdCBnYXAuIFRoZSBnYXBzIGdyb3cgYnkgMiBldmVyeSB0aW1lLiIsICJDb3JyZWN0LiBUaGVzZSBhcmUgc3F1YXJlIG51bWJlcnMg4oCUIDHCsiwgMsKyLCAzwrIsIDTCsiwgNcKyIOKAlCBzbyB0aGUgbmV4dCBpcyA2wrIgPSAzNi4iLCAiNDkgaXMgN8KyLiBJdCBza2lwcyBvdmVyIDbCsi4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-07', 'quantitative', 7, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgdHdvIHN0ZXBzIHRha2luZyB0dXJucw==', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogNSwgMTAsIDgsIDE2LCAxNCwgLi4uIFdoYXQgbnVtYmVyIHNob3VsZCBjb21lIG5leHQ/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxMiIsICIyOCIsICIxNiIsICIyMCJd', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('VGhlIG51bWJlcnMgZ28gdXAsIGRvd24sIHVwLCBkb3duIOKAlCBhIHNpZ24gdGhhdCB0d28gc3RlcHMgYXJlIHRha2luZyB0dXJucy4gV3JpdGUgZWFjaCBvbmU6IDUgdG8gMTAgaXMgw5cgMiwgMTAgdG8gOCBpcyDiiJIgMiwgOCB0byAxNiBpcyDDlyAyLCAxNiB0byAxNCBpcyDiiJIgMi4gVGhlIG5leHQgc3RlcCBpcyDDlyAyOiAxNCDDlyAyID0gMjgu', 'base64'), 'UTF8'),
 convert_from(decode('WyIxMiBzdWJ0cmFjdHMgMi4gQnV0IHRoZSBzdGVwcyBhbHRlcm5hdGUg4oCUIHRoZSBsYXN0IHN0ZXAgc3VidHJhY3RlZCwgc28gdGhpcyBvbmUgbXVsdGlwbGllcy4iLCAiQ29ycmVjdC4gVGhlIHBhdHRlcm4gYWx0ZXJuYXRlcyDDlyAyIHRoZW4g4oiSIDIuIFRoZSBsYXN0IHN0ZXAgd2FzIOKIkiAyICgxNiB0byAxNCksIHNvIG5vdyBtdWx0aXBseTogMTQgw5cgMiA9IDI4LiIsICIxNiBhZGRzIDIuIE5laXRoZXIgc3RlcCBpbiB0aGlzIHBhdHRlcm4gYWRkcy4iLCAiMjAgYWRkcyA2LiBMb29rIGF0IHRoZSBzdGVwcywgbm90IGp1c3QgdGhlIHNpemUgb2YgdGhlIG51bWJlcnMuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-08', 'quantitative', 8, convert_from(decode('TnVtYmVyIG1hbmlwdWxhdGlvbg==', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBudW1iZXIgaXMgNSBtb3JlIHRoYW4gMS8zIG9mIDI3Pw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIyMiIsICI5IiwgIjMyIiwgIjE0Il0=', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('QnJlYWsgdGhlIHNlbnRlbmNlIGF0IHRoZSB3b3JkICd0aGFuJzogJzUgbW9yZSB0aGFuJyAuLi4gJzEvMyBvZiAyNycuIERvIHRoZSBzZWNvbmQgcGFydCBmaXJzdCwgYmVjYXVzZSB0aGUgZmlyc3QgcGFydCBkZXBlbmRzIG9uIGl0OiAyNyDDtyAzID0gOS4gVGhlbiBhZGQgNTogMTQuIE1vc3QgbWlzdGFrZXMgY29tZSBmcm9tIHVzaW5nIHRoZSB3aG9sZSAyNyBpbnN0ZWFkIG9mIHRoZSB0aGlyZC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIyMiBpcyAyNyDiiJIgNS4gSXQgc2tpcHMgdGhlICdvbmUgdGhpcmQgb2YnIHN0ZXAgYW5kIHN1YnRyYWN0cyBpbnN0ZWFkIG9mIGFkZGluZy4iLCAiOSBpcyBvbmUgdGhpcmQgb2YgMjcg4oCUIHRoZSByaWdodCBmaXJzdCBzdGVwIOKAlCBidXQgeW91IHN0aWxsIG5lZWQgNSBtb3JlLiIsICIzMiBhZGRzIDUgdG8gMjcgYW5kIG5ldmVyIHRha2VzIGEgdGhpcmQuIiwgIkNvcnJlY3QuIE9uZSB0aGlyZCBvZiAyNyBpcyA5LCBhbmQgNSBtb3JlIHRoYW4gOSBpcyAxNC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-09', 'quantitative', 9, convert_from(decode('Q29tcGFyaXNvbnMg4oCUIHBlcmNlbnRzLCBmcmFjdGlvbnMsIGRlY2ltYWxz', 'base64'), 'UTF8'),
 convert_from(decode('RXhhbWluZSAoYSksIChiKSwgYW5kIChjKSBhbmQgZmluZCB0aGUgYmVzdCBhbnN3ZXIuCihhKSAyNSUgb2YgODAKKGIpIDEvNSBvZiAxMDAKKGMpIDAuMyDDlyA2MA==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIoYSkgYW5kIChiKSBhcmUgZXF1YWwsIGFuZCBib3RoIGFyZSBncmVhdGVyIHRoYW4gKGMpIiwgIihhKSwgKGIpLCBhbmQgKGMpIGFyZSBlcXVhbCIsICIoYykgaXMgZ3JlYXRlciB0aGFuIChhKSIsICIoYikgaXMgZ3JlYXRlciB0aGFuIChhKSJd', 'base64'), 'UTF8')::JSONB, 0, 2,
 convert_from(decode('Q29udmVydCBlYWNoIHRvIGEgcGxhaW4gbnVtYmVyLiAyNSUgaXMgb25lIHF1YXJ0ZXIsIGFuZCBhIHF1YXJ0ZXIgb2YgODAgaXMgMjAuIE9uZSBmaWZ0aCBvZiAxMDAgaXMgMjAuIEZvciAwLjMgw5cgNjAsIGZpbmQgMyDDlyA2MCA9IDE4MCwgdGhlbiBtb3ZlIHRoZSBkZWNpbWFsIG9uZSBwbGFjZTogMTguIFdpdGggZXZlcnl0aGluZyBhcyBhIHBsYWluIG51bWJlciwgdGhlIGNvbXBhcmlzb24gaXMgZWFzeS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiAoYSkgMjUlIG9mIDgwID0gMjAsIChiKSAxLzUgb2YgMTAwID0gMjAsIChjKSAwLjMgw5cgNjAgPSAxOC4gVGhlIGZpcnN0IHR3byB0aWUsIGFuZCBib3RoIGJlYXQgMTguIiwgIihjKSBpcyAxOCwgbm90IDIwIOKAlCBjbG9zZSBlbm91Z2ggdG8gZm9vbCBhIHF1aWNrIGVzdGltYXRlLCBidXQgbm90IGVxdWFsLiIsICIoYykgaXMgMTggYW5kIChhKSBpcyAyMCwgc28gKGMpIGlzIHNtYWxsZXIuIiwgIihhKSBhbmQgKGIpIGFyZSBib3RoIGV4YWN0bHkgMjAuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-10', 'quantitative', 10, convert_from(decode('Q29tcGFyaXNvbnMg4oCUIGV4cG9uZW50cyBhbmQgcm9vdHM=', 'base64'), 'UTF8'),
 convert_from(decode('RXhhbWluZSAoYSksIChiKSwgYW5kIChjKSBhbmQgZmluZCB0aGUgYmVzdCBhbnN3ZXIuCihhKSAzwrIKKGIpIDLCswooYykg4oiaNjQ=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIoYSksIChiKSwgYW5kIChjKSBhcmUgZXF1YWwiLCAiKGEpIGlzIGxlc3MgdGhhbiAoYykiLCAiKGIpIGlzIGdyZWF0ZXIgdGhhbiAoYykiLCAiKGIpIGFuZCAoYykgYXJlIGVxdWFsLCBhbmQgYm90aCBhcmUgbGVzcyB0aGFuIChhKSJd', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('VGhlIHNtYWxsIHJhaXNlZCBudW1iZXIgdGVsbHMgeW91IGhvdyBtYW55IHRpbWVzIHRvIG11bHRpcGx5IHRoZSBiYXNlIGJ5IGl0c2VsZjogM8KyID0gMyDDlyAzID0gOSwgYnV0IDLCsyA9IDIgw5cgMiDDlyAyID0gOC4gVGhlIOKImiBzaWduIGFza3Mgd2hpY2ggbnVtYmVyIHRpbWVzIGl0c2VsZiBtYWtlcyA2NDogOC4gV3JpdGUgdGhlIG11bHRpcGxpY2F0aW9uIG91dCByYXRoZXIgdGhhbiBndWVzc2luZyDigJQgM8KyIGFuZCAywrMgbG9vayBhbGlrZSBidXQgYXJlIG5vdCBlcXVhbC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIzwrIgaXMgOSwgbm90IDguIE1hbnkgc3R1ZGVudHMgbWl4IHVwIDPCsiBhbmQgMsKzIGJlY2F1c2UgdGhlIHNhbWUgZGlnaXRzIGFwcGVhci4iLCAiKGEpIGlzIDkgYW5kIChjKSBpcyA4LCBzbyAoYSkgaXMgdGhlIGxhcmdlciBvbmUuIiwgIjLCsyA9IDggYW5kIOKImjY0ID0gOCDigJQgdGhleSBhcmUgZXF1YWwuIiwgIkNvcnJlY3QuIDPCsiA9IDMgw5cgMyA9IDksIDLCsyA9IDIgw5cgMiDDlyAyID0gOCwgYW5kIOKImjY0ID0gOCwgc2luY2UgOCDDlyA4ID0gNjQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-11', 'quantitative', 11, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgZ3Jvd2luZyBnYXBz', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMiwgMywgNSwgOCwgMTIsIDE3LCAuLi4gV2hhdCBudW1iZXIgc2hvdWxkIGNvbWUgbmV4dD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIyMiIsICIyMyIsICIyNCIsICIyNSJd', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('VGhlIHN0YXJ0IOKAlCAyLCAzLCA1LCA4IOKAlCBsb29rcyBhcyBpZiBlYWNoIHRlcm0gaXMgdGhlIHN1bSBvZiB0aGUgdHdvIGJlZm9yZSBpdC4gQnV0IDUgKyA4ID0gMTMsIG5vdCAxMiwgc28gdGhhdCBydWxlIGJyZWFrcy4gQ2hlY2sgdGhlIGdhcHMgaW5zdGVhZDogMSwgMiwgMywgNCwgNS4gVGhleSBncm93IGJ5IG9uZSBlYWNoIHRpbWUsIHNvIHRoZSBuZXh0IGdhcCBpcyA2OiAxNyArIDYgPSAyMy4gQWx3YXlzIHRlc3QgYSBwYXR0ZXJuIGFnYWluc3QgZXZlcnkgdGVybSwgbm90IGp1c3QgdGhlIGZpcnN0IGZldy4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIyMiBhZGRzIDUsIHJlcGVhdGluZyB0aGUgbGFzdCBnYXAuIFRoZSBnYXBzIGFyZSBpbmNyZWFzaW5nIGJ5IDEgZWFjaCB0aW1lLiIsICJDb3JyZWN0LiBUaGUgZ2FwcyBhcmUgMSwgMiwgMywgNCwgNSwgc28gdGhlIG5leHQgZ2FwIGlzIDY6IDE3ICsgNiA9IDIzLiIsICIyNCBhZGRzIDcg4oCUIG9uZSBzdGVwIHRvbyBmYXIuIiwgIjI1IGFkZHMgdGhlIHR3byBwcmV2aW91cyBudW1iZXJzICg4ICsgMTcpLiBUaGF0IHJ1bGUgYnJlYWtzIGVhcmxpZXIgaW4gdGhlIHNlcmllczogNSArIDggPSAxMywgbm90IDEyLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-12', 'quantitative', 12, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgdHdvIG9wZXJhdGlvbnM=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogMywgNSwgOSwgMTcsIDMzLCAuLi4gV2hhdCBudW1iZXIgc2hvdWxkIGNvbWUgbmV4dD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyI0OSIsICI2NCIsICI2NSIsICI2NiJd', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('VGhlIGdhcHMgYXJlIDIsIDQsIDgsIDE2IOKAlCB0aGV5IGRvdWJsZSwgc28gdGhlIG5leHQgZ2FwIGlzIDMyOiAzMyArIDMyID0gNjUuIFRoZSBzYW1lIHBhdHRlcm4gd3JpdHRlbiBhcyBhIHJ1bGU6IGRvdWJsZSB0aGUgdGVybSBhbmQgc3VidHJhY3QgMSAoNSDDlyAyIOKIkiAxID0gOSwgOSDDlyAyIOKIkiAxID0gMTcpLiBXaGVuIHRoZSBnYXBzIHRoZW1zZWx2ZXMgZm9ybSBhIHBhdHRlcm4sIGZvbGxvdyB0aGUgZ2Fwcy4=', 'base64'), 'UTF8'),
 convert_from(decode('WyI0OSBhZGRzIDE2LCByZXBlYXRpbmcgdGhlIGxhc3QgZ2FwLiBUaGUgZ2FwcyBkb3VibGUg4oCUIDIsIDQsIDgsIDE2IOKAlCBzbyB0aGUgbmV4dCBpcyAzMi4iLCAiNjQgaXMgb25lIHNob3J0LiBEb3VibGluZyAzMyBnaXZlcyA2NiwgYW5kIHRoZSBydWxlIHN1YnRyYWN0cyAxLCBub3QgMi4iLCAiQ29ycmVjdC4gRWFjaCB0ZXJtIGlzIGRvdWJsZSB0aGUgb25lIGJlZm9yZSwgbWludXMgMTogMzMgw5cgMiDiiJIgMSA9IDY1LiIsICI2NiBkb3VibGVzIDMzIGJ1dCBmb3JnZXRzIHRvIHN1YnRyYWN0IDEuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-13', 'quantitative', 13, convert_from(decode('TnVtYmVyIHNlcmllcyDigJQgdHdvIHN0ZXBzIHRha2luZyB0dXJucw==', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBhdCB0aGlzIHNlcmllczogODAsIDQwLCA0NCwgMjIsIDI2LCAuLi4gV2hhdCBudW1iZXIgc2hvdWxkIGNvbWUgbmV4dD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxMyIsICIzMCIsICI1MiIsICIxMSJd', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('VGhlIHNlcmllcyBmYWxscyBhbmQgcmlzZXMsIHNvIHR3byBzdGVwcyBhcmUgYWx0ZXJuYXRpbmcuIExhYmVsIHRoZW06IDgwIHRvIDQwIGlzIMO3IDIsIDQwIHRvIDQ0IGlzICsgNCwgNDQgdG8gMjIgaXMgw7cgMiwgMjIgdG8gMjYgaXMgKyA0LiBUaGUgbmV4dCBzdGVwIGlzIMO3IDIsIGFwcGxpZWQgdG8gdGhlIGxhc3QgdGVybTogMjYgw7cgMiA9IDEzLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBUaGUgc3RlcHMgYWx0ZXJuYXRlIMO3IDIgdGhlbiArIDQuIFRoZSBsYXN0IHN0ZXAgd2FzICsgNCAoMjIgdG8gMjYpLCBzbyBub3cgaGFsdmU6IDI2IMO3IDIgPSAxMy4iLCAiMzAgYWRkcyA0IGFnYWluLCBidXQgdGhlIHN0ZXBzIHRha2UgdHVybnMg4oCUIGFmdGVyICsgNCBjb21lcyDDtyAyLiIsICI1MiBkb3VibGVzIDI2LiBUaGlzIHBhdHRlcm4gaGFsdmVzOyBpdCBuZXZlciBkb3VibGVzLiIsICIxMSBpcyAyMiDDtyAyIOKAlCB0aGUgcmlnaHQgb3BlcmF0aW9uIG9uIHRoZSB3cm9uZyBudW1iZXIuIEFwcGx5IHRoZSBuZXh0IHN0ZXAgdG8gdGhlIExBU1QgdGVybSwgMjYuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-14', 'quantitative', 14, convert_from(decode('TnVtYmVyIG1hbmlwdWxhdGlvbiDigJQgd29ya2luZyBiYWNrd2FyZA==', 'base64'), 'UTF8'),
 convert_from(decode('V2hlbiBhIG51bWJlciBpcyBkb3VibGVkIGFuZCB0aGVuIGRlY3JlYXNlZCBieSA3LCB0aGUgcmVzdWx0IGlzIDE1LiBXaGF0IGlzIHRoZSBudW1iZXI/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxMSIsICI0IiwgIjIyIiwgIjM3Il0=', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('V29yayBiYWNrd2FyZCwgdW5kb2luZyB0aGUgTEFTVCBzdGVwIGZpcnN0LiBUaGUgbGFzdCB0aGluZyBkb25lIHdhcyAnZGVjcmVhc2VkIGJ5IDcnLCBzbyBhZGQgNzogMTUgKyA3ID0gMjIuIEJlZm9yZSB0aGF0IGl0IHdhcyBkb3VibGVkLCBzbyBoYWx2ZTogMjIgw7cgMiA9IDExLiBBbHdheXMgY2hlY2sgYnkgcnVubmluZyBpdCBmb3J3YXJkOiAxMSDDlyAyID0gMjIsIGFuZCAyMiDiiJIgNyA9IDE1Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBVbmRvIGVhY2ggc3RlcCBpbiByZXZlcnNlOiAxNSArIDcgPSAyMiwgdGhlbiAyMiDDtyAyID0gMTEuIENoZWNrOiAxMSDDlyAyIOKIkiA3ID0gMTUuIiwgIjQgY29tZXMgZnJvbSBzdWJ0cmFjdGluZyA3IGluc3RlYWQgb2YgYWRkaW5nIGl0IGJhY2suIFRvIHVuZG8gJ2RlY3JlYXNlZCBieSA3JywgeW91IGFkZCA3LiIsICIyMiB1bmRvZXMgdGhlIHN1YnRyYWN0aW9uIGJ1dCBub3QgdGhlIGRvdWJsaW5nLiBEaXZpZGUgYnkgMiB0byBmaW5pc2guIiwgIjM3IHJ1bnMgdGhlIG9wZXJhdGlvbnMgZm9yd2FyZCBvbiAxNSAoMTUgw5cgMiArIDcpIGluc3RlYWQgb2YgdW5kb2luZyB0aGVtLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-quantitative-15', 'quantitative', 15, convert_from(decode('Q29tcGFyaXNvbnMg4oCUIG9yZGVyaW5nIHRocmVlIHZhbHVlcw==', 'base64'), 'UTF8'),
 convert_from(decode('RXhhbWluZSAoYSksIChiKSwgYW5kIChjKSBhbmQgZmluZCB0aGUgYmVzdCBhbnN3ZXIuCihhKSAyLzMKKGIpIDAuNgooYykgNjUl', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIoYykgaXMgZ3JlYXRlciB0aGFuIChhKSIsICIoYSkgYW5kIChjKSBhcmUgZXF1YWwiLCAiKGEpIGlzIGdyZWF0ZXIgdGhhbiAoYyksIGFuZCAoYykgaXMgZ3JlYXRlciB0aGFuIChiKSIsICIoYikgaXMgZ3JlYXRlciB0aGFuIChjKSJd', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('UHV0IGFsbCB0aHJlZSBpbiB0aGUgc2FtZSBmb3JtOyBkZWNpbWFscyBhcmUgZWFzaWVzdC4gMi8zID0gMC42NjYuLi4sIDY1JSA9IDAuNjUsIGFuZCAwLjYgPSAwLjYwLiBXcml0aW5nIDAuNjAgd2l0aCB0d28gcGxhY2VzIG1ha2VzIGl0IG9idmlvdXMgdGhhdCBpdCBzaXRzIGJlbG93IDAuNjUuIFdoZW4gdmFsdWVzIGFyZSBjbG9zZSwgYWRkIHplcm9zIHNvIHRoZSBkZWNpbWFscyBoYXZlIHRoZSBzYW1lIGxlbmd0aCBiZWZvcmUgeW91IGNvbXBhcmUu', 'base64'), 'UTF8'),
 convert_from(decode('WyI2NSUgaXMgMC42NSwgYnV0IDIvMyBpcyBhYm91dCAwLjY2NyDigJQganVzdCBiYXJlbHkgbGFyZ2VyLiIsICJUaGV5IGFyZSBjbG9zZSBidXQgbm90IGVxdWFsOiBhYm91dCAwLjY2NyB2ZXJzdXMgMC42NS4iLCAiQ29ycmVjdC4gQXMgZGVjaW1hbHM6IChhKSAyLzMg4omIIDAuNjY3LCAoYykgNjUlID0gMC42NSwgKGIpIDAuNi4gVGhlIG9yZGVyIGlzIGEsIHRoZW4gYywgdGhlbiBiLiIsICIwLjYgaXMgbGVzcyB0aGFuIDAuNjUg4oCUIHdyaXRlIGl0IGFzIDAuNjAgdG8gc2VlIGl0LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-01', 'reading', 1, convert_from(decode('Vm9jYWJ1bGFyeSDigJQgd29yZCBpbiBhIHBocmFzZQ==', 'base64'), 'UTF8'),
 convert_from(decode('Q2hvb3NlIHRoZSB3b3JkIHRoYXQgbWVhbnMgdGhlIHNhbWUgYXMgdGhlIGNhcGl0YWxpemVkIHdvcmQuCmEgUkFQSUQgcml2ZXI=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJzbG93IiwgImZhc3QiLCAiZGVlcCIsICJjb2xkIl0=', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('VGhlIHNob3J0IHBocmFzZSBnaXZlcyBjb250ZXh0LCBidXQgbm90aWNlIHRoYXQgc2V2ZXJhbCBjaG9pY2VzIGZpdCBhIHJpdmVyIOKAlCByaXZlcnMgY2FuIGJlIGRlZXAsIGNvbGQsIG9yIGZhc3QuIE9ubHkgb25lIG1hdGNoZXMgdGhlIG1lYW5pbmcgb2YgcmFwaWQgaXRzZWxmLiBEbyBub3QgcGljayBhIHdvcmQganVzdCBiZWNhdXNlIGl0IGZpdHMgdGhlIG5vdW47IHBpY2sgdGhlIG9uZSB0aGF0IG1lYW5zIHRoZSBzYW1lIGFzIHRoZSBjYXBpdGFsaXplZCB3b3JkLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJTbG93IGlzIHRoZSBPUFBPU0lURSBvZiByYXBpZCDigJQgdGhlIGNsYXNzaWMgdHJhcCBvbiBhIHNhbWUtbWVhbmluZyBxdWVzdGlvbi4iLCAiQ29ycmVjdC4gUmFwaWQgbWVhbnMgbW92aW5nIHF1aWNrbHkuIiwgIkRlZXAgZGVzY3JpYmVzIGEgcml2ZXIsIGJ1dCBpdCBoYXMgbm90aGluZyB0byBkbyB3aXRoIHNwZWVkLiIsICJDb2xkIGRlc2NyaWJlcyBhIHJpdmVyIHRvbywgYnV0IG5vdCBob3cgZmFzdCBpdCBtb3Zlcy4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-02', 'reading', 2, convert_from(decode('UmVhZGluZyDigJQgZmluZGluZyBhIGRldGFpbA==', 'base64'), 'UTF8'),
 convert_from(decode('QWNjb3JkaW5nIHRvIHRoZSBwYXNzYWdlLCB3aGF0IGRvZXMgdGhlIExFTkdUSCBvZiB0aGUgYmVlJ3Mgc3RyYWlnaHQgcnVuIHRlbGwgdGhlIG90aGVyIGJlZXM/', 'base64'), 'UTF8'),
 convert_from(decode('V2hlbiBhIGhvbmV5YmVlIGZpbmRzIGEgZ29vZCBwYXRjaCBvZiBmbG93ZXJzLCBzaGUgZG9lcyBub3Qga2VlcCBpdCB0byBoZXJzZWxmLiBTaGUgZmxpZXMgYmFjayB0byB0aGUgaGl2ZSBhbmQgcGVyZm9ybXMgYSBkYW5jZSBvbiB0aGUgd2FsbCBvZiB0aGUgaG9uZXljb21iLiBJbiB0aGlzICJ3YWdnbGUgZGFuY2UsIiB0aGUgYmVlIHJ1bnMgaW4gYSBzdHJhaWdodCBsaW5lIHdoaWxlIHNoYWtpbmcgaGVyIGJvZHkgZnJvbSBzaWRlIHRvIHNpZGUsIHRoZW4gY2lyY2xlcyBiYWNrIGFuZCByZXBlYXRzIHRoZSBydW4uCgpUaGUgZGFuY2UgaXMgYSBzZXQgb2YgZGlyZWN0aW9ucy4gVGhlIGFuZ2xlIG9mIHRoZSBzdHJhaWdodCBydW4gdGVsbHMgdGhlIG90aGVyIGJlZXMgd2hpY2ggd2F5IHRvIGZseSBjb21wYXJlZCB0byB0aGUgZGlyZWN0aW9uIG9mIHRoZSBzdW4uIFRoZSBsZW5ndGggb2YgdGhlIHJ1biB0ZWxscyB0aGVtIGhvdyBmYXIgYXdheSB0aGUgZmxvd2VycyBhcmU6IHRoZSBsb25nZXIgdGhlIGJlZSB3YWdnbGVzLCB0aGUgZmFydGhlciB0aGUgdHJpcC4gU2NpZW50aXN0cyB3aG8gc3R1ZGllZCB0aGUgZGFuY2Ugd2VyZSBhbWF6ZWQgdGhhdCBhbiBpbnNlY3QgY291bGQgc2hhcmUgc3VjaCBwcmVjaXNlIGluZm9ybWF0aW9uIHdpdGhvdXQgbWFraW5nIGEgc2luZ2xlIHNvdW5kLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJ3aGljaCBmbG93ZXJzIHNtZWxsIHRoZSBiZXN0IiwgImhvdyBtYW55IGJlZXMgc2hvdWxkIGdvIiwgIndoaWNoIHdheSB0aGUgc3VuIGlzIG1vdmluZyIsICJob3cgZmFyIGF3YXkgdGhlIGZsb3dlcnMgYXJlIl0=', 'base64'), 'UTF8')::JSONB, 3, 1,
 convert_from(decode('RGV0YWlsIHF1ZXN0aW9ucyBhcmUgYW5zd2VyZWQgYnkgb25lIHNwZWNpZmljIHNlbnRlbmNlLCBzbyBnbyBmaW5kIGl0LiBTZWFyY2ggZm9yIHRoZSB3b3JkICdsZW5ndGgnOiB0aGUgc2Vjb25kIHBhcmFncmFwaCBzYXlzIHRoZSBsZW5ndGggb2YgdGhlIHJ1biB0ZWxscyB0aGVtIGhvdyBmYXIgYXdheSB0aGUgZmxvd2VycyBhcmUuIE1hdGNoIHlvdXIgY2hvaWNlIHRvIHRoZSB0ZXh0IOKAlCBkbyBub3QgYW5zd2VyIGZyb20gd2hhdCBtZXJlbHkgc291bmRzIHJlYXNvbmFibGUu', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGUgcGFzc2FnZSBuZXZlciBtZW50aW9ucyBzbWVsbC4gVGhlIGRhbmNlIGlzIGFib3V0IGxvY2F0aW9uLCBub3Qgd2hpY2ggZmxvd2VycyBhcmUgYmVzdC4iLCAiVGhlIHBhc3NhZ2Ugc2F5cyBub3RoaW5nIGFib3V0IGhvdyBtYW55IGJlZXMgZ28uIEl0IGRlc2NyaWJlcyBvbmx5IGRpcmVjdGlvbiBhbmQgZGlzdGFuY2UuIiwgIlRoZSBzdW4gYXBwZWFycyBhcyBhIHJlZmVyZW5jZSBwb2ludCBmb3IgRElSRUNUSU9OLCBhbmQgZGlyZWN0aW9uIGNvbWVzIGZyb20gdGhlIGFuZ2xlIG9mIHRoZSBydW4sIG5vdCBpdHMgbGVuZ3RoLiIsICJDb3JyZWN0LiBUaGUgcGFzc2FnZSBzYXlzOiB0aGUgbG9uZ2VyIHRoZSBiZWUgd2FnZ2xlcywgdGhlIGZhcnRoZXIgdGhlIHRyaXAuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-03', 'reading', 3, convert_from(decode('UmVhZGluZyDigJQgZmluZGluZyBhIGRldGFpbA==', 'base64'), 'UTF8'),
 convert_from(decode('QWNjb3JkaW5nIHRvIHRoZSBwYXNzYWdlLCB0aGUgRXJpZSBDYW5hbCBjb25uZWN0ZWQgdGhlIEh1ZHNvbiBSaXZlciB0bw==', 'base64'), 'UTF8'),
 convert_from(decode('SW4gMTgxNywgdGhlIHN0YXRlIG9mIE5ldyBZb3JrIGJlZ2FuIGRpZ2dpbmcgYSBjYW5hbCB0aGF0IG1hbnkgcGVvcGxlIHRob3VnaHQgd2FzIGZvb2xpc2guIENyaXRpY3MgY2FsbGVkIGl0ICJDbGludG9uJ3MgRGl0Y2gsIiBhZnRlciBHb3Zlcm5vciBEZVdpdHQgQ2xpbnRvbiwgd2hvIGNoYW1waW9uZWQgdGhlIHBsYW4uIFRoZSBjYW5hbCB3b3VsZCBzdHJldGNoIDM2MyBtaWxlcywgY29ubmVjdGluZyB0aGUgSHVkc29uIFJpdmVyIGF0IEFsYmFueSB0byBMYWtlIEVyaWUgYXQgQnVmZmFsby4KCldoZW4gdGhlIEVyaWUgQ2FuYWwgb3BlbmVkIGluIDE4MjUsIHRoZSBjcml0aWNzIHdlcmUgcHJvdmVkIHdyb25nLiBCZWZvcmUgdGhlIGNhbmFsLCBtb3ZpbmcgZ29vZHMgb3ZlcmxhbmQgZnJvbSBCdWZmYWxvIHRvIE5ldyBZb3JrIENpdHkgY291bGQgdGFrZSB3ZWVrcyBhbmQgY29zdCBhIGZvcnR1bmUuIEJ5IGJvYXQsIHRoZSB0cmlwIGJlY2FtZSBtdWNoIGZhc3RlciwgYW5kIHRoZSBjb3N0IG9mIHNoaXBwaW5nIGRyb3BwZWQgYnkgcm91Z2hseSBuaW5ldHkgcGVyY2VudC4gRmFybSBnb29kcyBmcm9tIHRoZSBNaWR3ZXN0IHBvdXJlZCBlYXN0LCBhbmQgTmV3IFlvcmsgQ2l0eSBncmV3IGludG8gdGhlIGJ1c2llc3QgcG9ydCBpbiB0aGUgbmF0aW9uLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJ0aGUgQXRsYW50aWMgT2NlYW4iLCAiTmV3IFlvcmsgQ2l0eSIsICJMYWtlIEVyaWUiLCAidGhlIE1pc3Npc3NpcHBpIFJpdmVyIl0=', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('RmluZCB0aGUgc2VudGVuY2UgdGhhdCBhbnN3ZXJzIGl0IGRpcmVjdGx5OiB0aGUgY2FuYWwgd291bGQgY29ubmVjdCB0aGUgSHVkc29uIFJpdmVyIGF0IEFsYmFueSB0byBMYWtlIEVyaWUgYXQgQnVmZmFsby4gTmV3IFlvcmsgQ2l0eSBpcyBhIHRyYXAg4oCUIGl0IGlzIGluIHRoZSBwYXNzYWdlIGFuZCBpdCBtYXR0ZXJzIHRvIHRoZSBzdG9yeSwgYnV0IGl0IGlzIG5vdCB3aGF0IHRoZSBjYW5hbCBjb25uZWN0ZWQgdG8u', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGUgQXRsYW50aWMgaXMgbmV2ZXIgbWVudGlvbmVkLiBUaGUgY2FuYWwgcmFuIGlubGFuZCwgd2VzdCBmcm9tIHRoZSBIdWRzb24uIiwgIk5ldyBZb3JrIENpdHkgYmVuZWZpdGVkIGZyb20gdGhlIGNhbmFsLCBidXQgdGhlIGNhbmFsJ3Mgd2VzdGVybiBlbmQgd2FzIGF0IExha2UgRXJpZS4iLCAiQ29ycmVjdC4gVGhlIHBhc3NhZ2Ugc2F5cyBpdCBjb25uZWN0ZWQgdGhlIEh1ZHNvbiBSaXZlciBhdCBBbGJhbnkgdG8gTGFrZSBFcmllIGF0IEJ1ZmZhbG8uIiwgIlRoZSBNaXNzaXNzaXBwaSBkb2VzIG5vdCBhcHBlYXIgaW4gdGhlIHBhc3NhZ2UgYXQgYWxsLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-04', 'reading', 4, convert_from(decode('UmVhZGluZyDigJQgZmluZGluZyBhIGRldGFpbA==', 'base64'), 'UTF8'),
 convert_from(decode('QWNjb3JkaW5nIHRvIHRoZSBwYXNzYWdlLCB0cmVlcyBjb29sIHRoZSBhaXIgYmVjYXVzZQ==', 'base64'), 'UTF8'),
 convert_from(decode('RXZlcnkgY2l0eSBzaG91bGQgcGxhbnQgbW9yZSB0cmVlcyBhbG9uZyBpdHMgc3RyZWV0cy4gT24gYSBzdW1tZXIgYWZ0ZXJub29uLCBhIHNoYWRlZCBzaWRld2FsayBjYW4gYmUgbWFueSBkZWdyZWVzIGNvb2xlciB0aGFuIG9uZSBpbiBmdWxsIHN1biwgYW5kIHRyZWVzIGNvb2wgdGhlIGFpciBhcm91bmQgdGhlbSBhcyB3YXRlciBldmFwb3JhdGVzIGZyb20gdGhlaXIgbGVhdmVzLiBUaGF0IG1hdHRlcnMgdG8gYW55b25lIHdhaXRpbmcgZm9yIGEgYnVzIGluIEp1bHkuCgpUcmVlcyBhbHNvIHNvYWsgdXAgcmFpbndhdGVyIHRoYXQgd291bGQgb3RoZXJ3aXNlIHJ1c2ggaW50byBzdG9ybSBkcmFpbnMgYW5kIGZsb29kIGxvdyBzdHJlZXRzLiBTb21lIHBlb3BsZSBhcmd1ZSB0aGF0IHRyZWVzIGFyZSB0b28gZXhwZW5zaXZlIHRvIHBsYW50IGFuZCBjYXJlIGZvci4gQnV0IGEgeW91bmcgdHJlZSBjb3N0cyBmYXIgbGVzcyB0aGFuIHJlcGFpcmluZyBhIGZsb29kZWQgcm9hZCwgYW5kIGl0IGtlZXBzIHdvcmtpbmcgZm9yIGRlY2FkZXMuIEEgY2l0eSB0aGF0IHBsYW50cyB0cmVlcyB0b2RheSBpcyBub3Qgc3BlbmRpbmcgbW9uZXk7IGl0IGlzIHNhdmluZyBpdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJ0aGVpciBzaGFkZSBibG9ja3MgdGhlIHdpbmQiLCAid2F0ZXIgZXZhcG9yYXRlcyBmcm9tIHRoZWlyIGxlYXZlcyIsICJ0aGV5IHNvYWsgdXAgcmFpbndhdGVyIiwgInRoZXkgZ3JvdyB0YWxsZXIgaW4gc3VtbWVyIl0=', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('VGhlIHRyaWNraWVzdCB3cm9uZyBhbnN3ZXJzIGFyZSBUUlVFIHN0YXRlbWVudHMgZnJvbSBhIGRpZmZlcmVudCBwYXJ0IG9mIHRoZSBwYXNzYWdlLiBTb2FraW5nIHVwIHJhaW53YXRlciByZWFsbHkgaXMgaW4gdGhlIHRleHQg4oCUIGJ1dCBpdCBhbnN3ZXJzIGEgZGlmZmVyZW50IHF1ZXN0aW9uLiBBbHdheXMgY2hlY2sgdGhhdCB5b3VyIGNob2ljZSBhbnN3ZXJzIHRoZSBxdWVzdGlvbiBhc2tlZCwgbm90IGp1c3QgdGhhdCBpdCBhcHBlYXJzIHNvbWV3aGVyZS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJTaGFkZSBibG9ja3Mgc3VubGlnaHQsIG5vdCB3aW5kLCBhbmQgdGhlIHBhc3NhZ2UgbmV2ZXIgbWVudGlvbnMgd2luZC4iLCAiQ29ycmVjdC4gVGhlIHBhc3NhZ2Ugc2F5cyB0cmVlcyBjb29sIHRoZSBhaXIgYXJvdW5kIHRoZW0gYXMgd2F0ZXIgZXZhcG9yYXRlcyBmcm9tIHRoZWlyIGxlYXZlcy4iLCAiU29ha2luZyB1cCByYWluIGlzIGEgcmVhbCBiZW5lZml0IGluIHRoZSBwYXNzYWdlLCBidXQgaXQgZXhwbGFpbnMgZmxvb2QgY29udHJvbCwgbm90IGNvb2xpbmcuIiwgIkdyb3d0aCBpcyBuZXZlciBtZW50aW9uZWQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-05', 'reading', 5, convert_from(decode('UmVhZGluZyDigJQgZmluZGluZyBhIGRldGFpbA==', 'base64'), 'UTF8'),
 convert_from(decode('QWNjb3JkaW5nIHRvIHRoZSBwYXNzYWdlLCB3aGF0IGFyZSBjaHJvbWF0b3Bob3Jlcz8=', 'base64'), 'UTF8'),
 convert_from(decode('QW4gb2N0b3B1cyBjYW4gY2hhbmdlIGNvbG9yIGluIGxlc3MgdGhhbiBhIHNlY29uZC4gSXRzIHNraW4gaG9sZHMgdGhvdXNhbmRzIG9mIHRpbnkgc2FjcyBvZiBwaWdtZW50IGNhbGxlZCBjaHJvbWF0b3Bob3JlcywgYW5kIGVhY2ggc2FjIGlzIHJpbmdlZCBieSBtdXNjbGVzLiBXaGVuIHRoZSBtdXNjbGVzIHB1bGwsIHRoZSBzYWMgc3RyZXRjaGVzIHdpZGUgYW5kIGl0cyBjb2xvciBzcHJlYWRzIGFjcm9zcyBhIHBhdGNoIG9mIHNraW47IHdoZW4gdGhleSByZWxheCwgdGhlIHNhYyBzaHJpbmtzIHRvIGEgZG90IHRvbyBzbWFsbCB0byBzZWUuCgpCZWNhdXNlIHRoZXNlIG11c2NsZXMgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLCBhbiBvY3RvcHVzIGNhbiByZXNoYXBlIHRoZSBwYXR0ZXJucyBvbiBpdHMgYm9keSBhbG1vc3QgaW5zdGFudGx5LiBJdCB1c2VzIHRoaXMgc2tpbGwgdG8gdmFuaXNoIGFnYWluc3QgYSByb2NreSBzZWFmbG9vciwgdG8gc3RhcnRsZSBhIHByZWRhdG9yIHdpdGggYSBzdWRkZW4gZmxhc2ggb2YgZGFyayBjb2xvciwgb3IgdG8gc2lnbmFsIHRvIG90aGVyIG9jdG9wdXNlcy4gVGhlIHNhbWUgYW5pbWFsIHRoYXQgY2FuIHNxdWVlemUgdGhyb3VnaCBhIGdhcCB0aGUgc2l6ZSBvZiBhIGNvaW4gY2FuIGFsc28gZGlzYXBwZWFyIGluIHBsYWluIHNpZ2h0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJ0aW55IHNhY3Mgb2YgcGlnbWVudCBpbiB0aGUgc2tpbiIsICJtdXNjbGVzIHRoYXQgbW92ZSB0aGUgb2N0b3B1cydzIGFybXMiLCAibmVydmVzIHRoYXQgY29udHJvbCBicmVhdGhpbmciLCAicGF0dGVybnMgb24gdGhlIHNlYWZsb29yIl0=', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('V2hlbiBhIHBhc3NhZ2UgaW50cm9kdWNlcyBhIHRlY2huaWNhbCB3b3JkLCBpdCBhbG1vc3QgYWx3YXlzIGRlZmluZXMgaXQgaW4gdGhlIHNhbWUgc2VudGVuY2Ug4oCUIGxvb2sgZm9yICdjYWxsZWQnIG9yIGEgY29tbWEgcmlnaHQgYWZ0ZXIgdGhlIG5ldyB3b3JkLiBIZXJlOiB0aW55IHNhY3Mgb2YgcGlnbWVudCBjYWxsZWQgY2hyb21hdG9waG9yZXMuIFRoZSBvdGhlciBjaG9pY2VzIGJvcnJvdyByZWFsIHdvcmRzIGZyb20gdGhlIHBhc3NhZ2UgYnV0IGF0dGFjaCB0aGVtIHRvIHRoZSB3cm9uZyB0aGluZy4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBUaGUgcGFzc2FnZSBkZWZpbmVzIHRoZW0gYXMgdGlueSBzYWNzIG9mIHBpZ21lbnQgaW4gdGhlIG9jdG9wdXMncyBza2luLiIsICJUaGUgbXVzY2xlcyBpbiB0aGUgcGFzc2FnZSBzdXJyb3VuZCB0aGUgcGlnbWVudCBzYWNzOyB0aGV5IGRvIG5vdCBtb3ZlIHRoZSBhcm1zLiIsICJOZXJ2ZXMgYXJlIG1lbnRpb25lZCwgYnV0IHRoZXkgY29udHJvbCB0aGUgbXVzY2xlcyBhcm91bmQgdGhlIHNhY3MsIG5vdCBicmVhdGhpbmcuIiwgIlRoZSBzZWFmbG9vciBpcyB3aGVyZSBhbiBvY3RvcHVzIGhpZGVzLCBub3Qgd2hhdCBhIGNocm9tYXRvcGhvcmUgaXMuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-06', 'reading', 6, convert_from(decode('Vm9jYWJ1bGFyeSDigJQgd29yZCBpbiBhIHBocmFzZQ==', 'base64'), 'UTF8'),
 convert_from(decode('Q2hvb3NlIHRoZSB3b3JkIHRoYXQgbWVhbnMgdGhlIHNhbWUgYXMgdGhlIGNhcGl0YWxpemVkIHdvcmQuCmEgQ0FVVElPVVMgZHJpdmVy', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJjYXJlZnVsIiwgInNwZWVkeSIsICJza2lsbGVkIiwgIm5lcnZvdXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 2,
 convert_from(decode('Q2F1dGlvdXMgbWVhbnMgY2FyZWZ1bCB0byBhdm9pZCBkYW5nZXIuIFRoZSBoYXJkIHBhcnQgaXMgdGhlIG5lYXItbWlzczogbmVydm91cyBwZW9wbGUgYXJlIG9mdGVuIGNhdXRpb3VzLCBzbyBpdCBmZWVscyBjbG9zZS4gQnV0IHRoZSBxdWVzdGlvbiBhc2tzIHdoYXQgdGhlIHdvcmQgTUVBTlMsIG5vdCB3aG8gdGVuZHMgdG8gYWN0IHRoYXQgd2F5LiBBIGNhbG0gZHJpdmVyIGNhbiBiZSBjYXV0aW91cywgYW5kIGEgbmVydm91cyBvbmUgY2FuIGJlIHJlY2tsZXNzLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBBIGNhdXRpb3VzIGRyaXZlciB0YWtlcyBjYXJlIHRvIGF2b2lkIGRhbmdlci4iLCAiU3BlZWR5IGlzIG5lYXJseSB0aGUgb3Bwb3NpdGUg4oCUIGNhdXRpb24gdXN1YWxseSBtZWFucyBzbG93aW5nIGRvd24uIiwgIkEgZHJpdmVyIGNhbiBiZSBza2lsbGVkIHdpdGhvdXQgYmVpbmcgY2F1dGlvdXMuIFNraWxsIGlzIGFiaWxpdHk7IGNhdXRpb24gaXMgYXR0aXR1ZGUuIiwgIk5lcnZvdXMgZGVzY3JpYmVzIGEgZmVlbGluZy4gQSBjYXV0aW91cyBkcml2ZXIgbWF5IGJlIHBlcmZlY3RseSBjYWxtIOKAlCBjYXV0aW9uIGlzIGFib3V0IGNob2ljZXMsIG5vdCB3b3JyeS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-07', 'reading', 7, convert_from(decode('UmVhZGluZyDigJQgbWFpbiBpZGVh', 'base64'), 'UTF8'),
 convert_from(decode('V2hpY2ggdGl0bGUgYmVzdCBmaXRzIHRoaXMgcGFzc2FnZT8=', 'base64'), 'UTF8'),
 convert_from(decode('V2hlbiBhIGhvbmV5YmVlIGZpbmRzIGEgZ29vZCBwYXRjaCBvZiBmbG93ZXJzLCBzaGUgZG9lcyBub3Qga2VlcCBpdCB0byBoZXJzZWxmLiBTaGUgZmxpZXMgYmFjayB0byB0aGUgaGl2ZSBhbmQgcGVyZm9ybXMgYSBkYW5jZSBvbiB0aGUgd2FsbCBvZiB0aGUgaG9uZXljb21iLiBJbiB0aGlzICJ3YWdnbGUgZGFuY2UsIiB0aGUgYmVlIHJ1bnMgaW4gYSBzdHJhaWdodCBsaW5lIHdoaWxlIHNoYWtpbmcgaGVyIGJvZHkgZnJvbSBzaWRlIHRvIHNpZGUsIHRoZW4gY2lyY2xlcyBiYWNrIGFuZCByZXBlYXRzIHRoZSBydW4uCgpUaGUgZGFuY2UgaXMgYSBzZXQgb2YgZGlyZWN0aW9ucy4gVGhlIGFuZ2xlIG9mIHRoZSBzdHJhaWdodCBydW4gdGVsbHMgdGhlIG90aGVyIGJlZXMgd2hpY2ggd2F5IHRvIGZseSBjb21wYXJlZCB0byB0aGUgZGlyZWN0aW9uIG9mIHRoZSBzdW4uIFRoZSBsZW5ndGggb2YgdGhlIHJ1biB0ZWxscyB0aGVtIGhvdyBmYXIgYXdheSB0aGUgZmxvd2VycyBhcmU6IHRoZSBsb25nZXIgdGhlIGJlZSB3YWdnbGVzLCB0aGUgZmFydGhlciB0aGUgdHJpcC4gU2NpZW50aXN0cyB3aG8gc3R1ZGllZCB0aGUgZGFuY2Ugd2VyZSBhbWF6ZWQgdGhhdCBhbiBpbnNlY3QgY291bGQgc2hhcmUgc3VjaCBwcmVjaXNlIGluZm9ybWF0aW9uIHdpdGhvdXQgbWFraW5nIGEgc2luZ2xlIHNvdW5kLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJIb3cgQmVlcyBNYWtlIEhvbmV5IiwgIkEgRGFuY2UgVGhhdCBHaXZlcyBEaXJlY3Rpb25zIiwgIldoeSBCZWVzIEZseSBUb3dhcmQgdGhlIFN1biIsICJUaGUgU2NpZW50aXN0cyBXaG8gU3R1ZGllZCBJbnNlY3RzIl0=', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('QSBnb29kIHRpdGxlIGNvdmVycyB0aGUgV0hPTEUgcGFzc2FnZSwgbm90IG9uZSBzZW50ZW5jZSBvZiBpdC4gQXNrIHdoYXQgYm90aCBwYXJhZ3JhcGhzIGFyZSBhYm91dDogdGhlIGZpcnN0IGRlc2NyaWJlcyB0aGUgZGFuY2UsIHRoZSBzZWNvbmQgZXhwbGFpbnMgd2hhdCBpdCBjb21tdW5pY2F0ZXMuIFRpdGxlcyB0aGF0IGZpdCBvbmx5IGEgc2luZ2xlIHNlbnRlbmNlIOKAlCBvciBubyBzZW50ZW5jZSDigJQgYXJlIHRvbyBuYXJyb3cgb3Igc2ltcGx5IHdyb25nLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJIb25leS1tYWtpbmcgaXMgbmV2ZXIgZGVzY3JpYmVkLiBBIHRpdGxlIG11c3QgY292ZXIgd2hhdCB0aGUgcGFzc2FnZSBpcyBhY3R1YWxseSBhYm91dC4iLCAiQ29ycmVjdC4gQm90aCBwYXJhZ3JhcGhzIGJ1aWxkIHRvd2FyZCBvbmUgaWRlYTogdGhlIHdhZ2dsZSBkYW5jZSB0ZWxscyBvdGhlciBiZWVzIHdoZXJlIHRoZSBmbG93ZXJzIGFyZS4iLCAiQmVlcyBkbyBub3QgZmx5IHRvd2FyZCB0aGUgc3VuIGluIHRoZSBwYXNzYWdlOyB0aGUgc3VuIGlzIG9ubHkgYSByZWZlcmVuY2UgZm9yIGRpcmVjdGlvbi4gVGhpcyB0aXRsZSBtaXNyZWFkcyBhIGRldGFpbC4iLCAiU2NpZW50aXN0cyBhcHBlYXIgaW4gb25lIGNsb3Npbmcgc2VudGVuY2UuIEEgdGl0bGUgYnVpbHQgb24gYSBzbWFsbCBkZXRhaWwgaXMgdG9vIG5hcnJvdy4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-08', 'reading', 8, convert_from(decode('UmVhZGluZyDigJQgd29yZCBpbiBjb250ZXh0', 'base64'), 'UTF8'),
 convert_from(decode('SW4gdGhlIHBhc3NhZ2UsIHRoZSB3b3JkICJjaGFtcGlvbmVkIiBtb3N0IG5lYXJseSBtZWFucw==', 'base64'), 'UTF8'),
 convert_from(decode('SW4gMTgxNywgdGhlIHN0YXRlIG9mIE5ldyBZb3JrIGJlZ2FuIGRpZ2dpbmcgYSBjYW5hbCB0aGF0IG1hbnkgcGVvcGxlIHRob3VnaHQgd2FzIGZvb2xpc2guIENyaXRpY3MgY2FsbGVkIGl0ICJDbGludG9uJ3MgRGl0Y2gsIiBhZnRlciBHb3Zlcm5vciBEZVdpdHQgQ2xpbnRvbiwgd2hvIGNoYW1waW9uZWQgdGhlIHBsYW4uIFRoZSBjYW5hbCB3b3VsZCBzdHJldGNoIDM2MyBtaWxlcywgY29ubmVjdGluZyB0aGUgSHVkc29uIFJpdmVyIGF0IEFsYmFueSB0byBMYWtlIEVyaWUgYXQgQnVmZmFsby4KCldoZW4gdGhlIEVyaWUgQ2FuYWwgb3BlbmVkIGluIDE4MjUsIHRoZSBjcml0aWNzIHdlcmUgcHJvdmVkIHdyb25nLiBCZWZvcmUgdGhlIGNhbmFsLCBtb3ZpbmcgZ29vZHMgb3ZlcmxhbmQgZnJvbSBCdWZmYWxvIHRvIE5ldyBZb3JrIENpdHkgY291bGQgdGFrZSB3ZWVrcyBhbmQgY29zdCBhIGZvcnR1bmUuIEJ5IGJvYXQsIHRoZSB0cmlwIGJlY2FtZSBtdWNoIGZhc3RlciwgYW5kIHRoZSBjb3N0IG9mIHNoaXBwaW5nIGRyb3BwZWQgYnkgcm91Z2hseSBuaW5ldHkgcGVyY2VudC4gRmFybSBnb29kcyBmcm9tIHRoZSBNaWR3ZXN0IHBvdXJlZCBlYXN0LCBhbmQgTmV3IFlvcmsgQ2l0eSBncmV3IGludG8gdGhlIGJ1c2llc3QgcG9ydCBpbiB0aGUgbmF0aW9uLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJkZWZlYXRlZCIsICJ3b24gYSBjb250ZXN0IGZvciIsICJxdWVzdGlvbmVkIiwgInN0cm9uZ2x5IHN1cHBvcnRlZCJd', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('V2hlbiBhIGZhbWlsaWFyIHdvcmQgYXBwZWFycyBpbiBhbiB1bnVzdWFsIHJvbGUsIHRydXN0IHRoZSBzZW50ZW5jZSBvdmVyIHlvdXIgZmlyc3QgYXNzb2NpYXRpb24uIENoYW1waW9uIHVzdWFsbHkgbWVhbnMgYSB3aW5uZXIsIGJ1dCBoZXJlIGl0IGlzIHNvbWV0aGluZyBhIGdvdmVybm9yIGRvZXMgdG8gYSBwbGFuLiBUaGUgY3JpdGljcyBhdHRhY2hlZCBoaXMgbmFtZSB0byB0aGUgY2FuYWwsIHNvIGhlIG11c3QgaGF2ZSBiZWVuIGl0cyBsZWFkaW5nIHN1cHBvcnRlci4gVHJ5IGVhY2ggY2hvaWNlIGluIHRoZSBzZW50ZW5jZSBhbmQga2VlcCB0aGUgb25lIHRoYXQgbWFrZXMgc2Vuc2Uu', 'base64'), 'UTF8'),
 convert_from(decode('WyJEZWZlYXRpbmcgYSBwbGFuIGlzIHRoZSBvcHBvc2l0ZSBvZiB3aGF0IENsaW50b24gZGlkIOKAlCB0aGUgY2FuYWwgd2FzIG5pY2tuYW1lZCBhZnRlciBoaW0gYmVjYXVzZSBoZSBiYWNrZWQgaXQuIiwgIlRoaXMgaXMgdGhlIGV2ZXJ5ZGF5IG1lYW5pbmcgb2YgY2hhbXBpb24sIGEgc3BvcnRzIHdpbm5lci4gSW4gdGhpcyBzZW50ZW5jZSB0aGUgd29yZCBpcyBhbiBhY3Rpb24gc29tZW9uZSB0YWtlcyB0b3dhcmQgYSBwbGFuLiIsICJRdWVzdGlvbmluZyB0aGUgcGxhbiBpcyB3aGF0IHRoZSBjcml0aWNzIGRpZCwgbm90IENsaW50b24uIiwgIkNvcnJlY3QuIENsaW50b24gY2hhbXBpb25lZCB0aGUgcGxhbiwgbWVhbmluZyBoZSBhcmd1ZWQgZm9yIGl0IOKAlCB3aGljaCBpcyB3aHkgY3JpdGljcyB0aWVkIGhpcyBuYW1lIHRvIGl0LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-09', 'reading', 9, convert_from(decode('UmVhZGluZyDigJQgbWFpbiBpZGVh', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyB0aGUgYXV0aG9yJ3MgbWFpbiBwb2ludD8=', 'base64'), 'UTF8'),
 convert_from(decode('RXZlcnkgY2l0eSBzaG91bGQgcGxhbnQgbW9yZSB0cmVlcyBhbG9uZyBpdHMgc3RyZWV0cy4gT24gYSBzdW1tZXIgYWZ0ZXJub29uLCBhIHNoYWRlZCBzaWRld2FsayBjYW4gYmUgbWFueSBkZWdyZWVzIGNvb2xlciB0aGFuIG9uZSBpbiBmdWxsIHN1biwgYW5kIHRyZWVzIGNvb2wgdGhlIGFpciBhcm91bmQgdGhlbSBhcyB3YXRlciBldmFwb3JhdGVzIGZyb20gdGhlaXIgbGVhdmVzLiBUaGF0IG1hdHRlcnMgdG8gYW55b25lIHdhaXRpbmcgZm9yIGEgYnVzIGluIEp1bHkuCgpUcmVlcyBhbHNvIHNvYWsgdXAgcmFpbndhdGVyIHRoYXQgd291bGQgb3RoZXJ3aXNlIHJ1c2ggaW50byBzdG9ybSBkcmFpbnMgYW5kIGZsb29kIGxvdyBzdHJlZXRzLiBTb21lIHBlb3BsZSBhcmd1ZSB0aGF0IHRyZWVzIGFyZSB0b28gZXhwZW5zaXZlIHRvIHBsYW50IGFuZCBjYXJlIGZvci4gQnV0IGEgeW91bmcgdHJlZSBjb3N0cyBmYXIgbGVzcyB0aGFuIHJlcGFpcmluZyBhIGZsb29kZWQgcm9hZCwgYW5kIGl0IGtlZXBzIHdvcmtpbmcgZm9yIGRlY2FkZXMuIEEgY2l0eSB0aGF0IHBsYW50cyB0cmVlcyB0b2RheSBpcyBub3Qgc3BlbmRpbmcgbW9uZXk7IGl0IGlzIHNhdmluZyBpdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJUcmVlcyBhcmUgdG9vIGV4cGVuc2l2ZSBmb3IgbW9zdCBjaXRpZXMgdG8gY2FyZSBmb3IuIiwgIldhaXRpbmcgZm9yIGEgYnVzIGluIHN1bW1lciBpcyB1bnBsZWFzYW50LiIsICJDaXRpZXMgc2hvdWxkIHBsYW50IG1vcmUgc3RyZWV0IHRyZWVzIGJlY2F1c2UgdGhleSBwYXkgZm9yIHRoZW1zZWx2ZXMuIiwgIlN0b3JtIGRyYWlucyBpbiBtb3N0IGNpdGllcyBhcmUgcG9vcmx5IGJ1aWx0LiJd', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('SW4gYSBwZXJzdWFzaXZlIHBhc3NhZ2UsIHRoZSBtYWluIHBvaW50IGlzIHRoZSBjbGFpbSBldmVyeXRoaW5nIGVsc2Ugc3VwcG9ydHMg4oCUIHVzdWFsbHkgc3RhdGVkIGluIHRoZSBmaXJzdCBvciBsYXN0IHNlbnRlbmNlLiBIZXJlIHRoZSBmaXJzdCBzYXlzIGNpdGllcyBzaG91bGQgcGxhbnQgbW9yZSB0cmVlcywgYW5kIHRoZSBsYXN0IGV4cGxhaW5zIHdoeSBpdCBzYXZlcyBtb25leS4gQmUgY2FyZWZ1bCB3aXRoIG9wcG9zaW5nIHZpZXdzOiBhbiBhdXRob3Igb2Z0ZW4gbWVudGlvbnMgb25lIG9ubHkgdG8gYW5zd2VyIGl0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGlzIGlzIHRoZSBvYmplY3Rpb24gdGhlIGF1dGhvciByYWlzZXMgaW4gb3JkZXIgdG8gcmVqZWN0IGl0LiBNZW50aW9uaW5nIGFuIG9wcG9zaW5nIHZpZXcgaXMgbm90IGFncmVlaW5nIHdpdGggaXQuIiwgIlRoZSBidXMgc3RvcCBpcyBvbmUgZXhhbXBsZSBvZiB3aHkgc2hhZGUgbWF0dGVycywgbm90IHRoZSBwb2ludCBvZiB0aGUgcGFzc2FnZS4iLCAiQ29ycmVjdC4gVGhlIGZpcnN0IHNlbnRlbmNlIHN0YXRlcyB0aGUgY2xhaW0sIGFuZCBldmVyeSBwYXJhZ3JhcGggc3VwcG9ydHMgaXQsIGVuZGluZyB3aXRoICdpdCBpcyBzYXZpbmcgaXQuJyIsICJTdG9ybSBkcmFpbnMgYXBwZWFyIG9ubHkgYXMgcGFydCBvZiB0aGUgZmxvb2RpbmcgYXJndW1lbnQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-10', 'reading', 10, convert_from(decode('UmVhZGluZyDigJQgY2F1c2UgYW5kIGVmZmVjdA==', 'base64'), 'UTF8'),
 convert_from(decode('QWNjb3JkaW5nIHRvIHRoZSBwYXNzYWdlLCB3aHkgY2FuIGFuIG9jdG9wdXMgY2hhbmdlIGl0cyBwYXR0ZXJucyBzbyBxdWlja2x5Pw==', 'base64'), 'UTF8'),
 convert_from(decode('QW4gb2N0b3B1cyBjYW4gY2hhbmdlIGNvbG9yIGluIGxlc3MgdGhhbiBhIHNlY29uZC4gSXRzIHNraW4gaG9sZHMgdGhvdXNhbmRzIG9mIHRpbnkgc2FjcyBvZiBwaWdtZW50IGNhbGxlZCBjaHJvbWF0b3Bob3JlcywgYW5kIGVhY2ggc2FjIGlzIHJpbmdlZCBieSBtdXNjbGVzLiBXaGVuIHRoZSBtdXNjbGVzIHB1bGwsIHRoZSBzYWMgc3RyZXRjaGVzIHdpZGUgYW5kIGl0cyBjb2xvciBzcHJlYWRzIGFjcm9zcyBhIHBhdGNoIG9mIHNraW47IHdoZW4gdGhleSByZWxheCwgdGhlIHNhYyBzaHJpbmtzIHRvIGEgZG90IHRvbyBzbWFsbCB0byBzZWUuCgpCZWNhdXNlIHRoZXNlIG11c2NsZXMgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLCBhbiBvY3RvcHVzIGNhbiByZXNoYXBlIHRoZSBwYXR0ZXJucyBvbiBpdHMgYm9keSBhbG1vc3QgaW5zdGFudGx5LiBJdCB1c2VzIHRoaXMgc2tpbGwgdG8gdmFuaXNoIGFnYWluc3QgYSByb2NreSBzZWFmbG9vciwgdG8gc3RhcnRsZSBhIHByZWRhdG9yIHdpdGggYSBzdWRkZW4gZmxhc2ggb2YgZGFyayBjb2xvciwgb3IgdG8gc2lnbmFsIHRvIG90aGVyIG9jdG9wdXNlcy4gVGhlIHNhbWUgYW5pbWFsIHRoYXQgY2FuIHNxdWVlemUgdGhyb3VnaCBhIGdhcCB0aGUgc2l6ZSBvZiBhIGNvaW4gY2FuIGFsc28gZGlzYXBwZWFyIGluIHBsYWluIHNpZ2h0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJJdHMgc2tpbiBpcyBleHRyZW1lbHkgdGhpbi4iLCAiSXQgY2FuIHNlZSBldmVyeSBjb2xvciBhcm91bmQgaXQuIiwgIkl0IGxpdmVzIG9uIHJvY2t5IHNlYWZsb29ycy4iLCAiVGhlIG11c2NsZXMgYXJvdW5kIGl0cyBwaWdtZW50IHNhY3MgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLiJd', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('Q2F1c2UtYW5kLWVmZmVjdCBxdWVzdGlvbnMgb2Z0ZW4gaGF2ZSBhIHNpZ25hbCB3b3JkIGluIHRoZSBwYXNzYWdlIOKAlCBiZWNhdXNlLCBzbywgYXMgYSByZXN1bHQuIFNlYXJjaCBmb3IgaXQ6ICdCZWNhdXNlIHRoZXNlIG11c2NsZXMgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLCBhbiBvY3RvcHVzIGNhbiByZXNoYXBlIHRoZSBwYXR0ZXJucyBvbiBpdHMgYm9keSBhbG1vc3QgaW5zdGFudGx5LicgVGhlIHdvcmQgJ2JlY2F1c2UnIHBvaW50cyBzdHJhaWdodCBhdCB0aGUgY2F1c2Uu', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGUgdGhpY2tuZXNzIG9mIHRoZSBza2luIGlzIG5ldmVyIG1lbnRpb25lZC4iLCAiVGhlIHBhc3NhZ2Ugc2F5cyBub3RoaW5nIGFib3V0IHRoZSBvY3RvcHVzJ3MgZXllc2lnaHQuIiwgIlRoZSBzZWFmbG9vciBpcyB3aGVyZSBpdCBoaWRlcywgbm90IHdoYXQgbWFrZXMgdGhlIGNoYW5nZSBmYXN0LiIsICJDb3JyZWN0LiBUaGUgcGFzc2FnZSBzYXlzOiBiZWNhdXNlIHRoZXNlIG11c2NsZXMgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLCBhbiBvY3RvcHVzIGNhbiByZXNoYXBlIGl0cyBwYXR0ZXJucyBhbG1vc3QgaW5zdGFudGx5LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-11', 'reading', 11, convert_from(decode('Vm9jYWJ1bGFyeSDigJQgd29yZCBpbiBhIHBocmFzZQ==', 'base64'), 'UTF8'),
 convert_from(decode('Q2hvb3NlIHRoZSB3b3JkIHRoYXQgbWVhbnMgdGhlIHNhbWUgYXMgdGhlIGNhcGl0YWxpemVkIHdvcmQuCmFuIEFVU1RFUkUgcm9vbQ==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJsdXh1cmlvdXMiLCAiY3Jvd2RlZCIsICJwbGFpbiBhbmQgYmFyZSIsICJicmlnaHRseSBsaXQiXQ==', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('QXVzdGVyZSBtZWFucyBzZXZlcmVseSBzaW1wbGUg4oCUIG5vIGRlY29yYXRpb24sIG5vIGx1eHVyeS4gSWYgeW91IGRvIG5vdCBrbm93IGl0LCBub3RpY2UgdGhhdCBpdCBzb3VuZHMgc3Rlcm47IHdvcmRzIGRlc2NyaWJpbmcgc3RyaWN0bmVzcyBvZnRlbiBkZXNjcmliZSBwbGFpbm5lc3MgdG9vLiBUaGVuIGVsaW1pbmF0ZSB3aGF0IHlvdSBjYW46IGx1eHVyaW91cyBpcyB0aGUgb3Bwb3NpdGUsIGFuZCBjcm93ZGVkIGFuZCBicmlnaHRseSBsaXQgZGVzY3JpYmUgb3RoZXIgcXVhbGl0aWVzIG9mIGEgcm9vbSBlbnRpcmVseS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJMdXh1cmlvdXMgaXMgdGhlIG9wcG9zaXRlIOKAlCByaWNoIGFuZCBjb21mb3J0YWJsZS4gQXVzdGVyZSBtZWFucyB3aXRob3V0IGNvbWZvcnRzLiIsICJBdXN0ZXJlIGRlc2NyaWJlcyBob3cgYSByb29tIGlzIGZ1cm5pc2hlZCwgbm90IGhvdyBtYW55IHBlb3BsZSBhcmUgaW4gaXQuIiwgIkNvcnJlY3QuIEFuIGF1c3RlcmUgcm9vbSBpcyBzaW1wbGUgYW5kIHVuZGVjb3JhdGVkLCB3aXRoIG5vdGhpbmcgZXh0cmEuIiwgIkxpZ2h0aW5nIGlzIG5vdCBwYXJ0IG9mIHRoZSB3b3JkJ3MgbWVhbmluZy4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-12', 'reading', 12, convert_from(decode('UmVhZGluZyDigJQgaW5mZXJlbmNl', 'base64'), 'UTF8'),
 convert_from(decode('VGhlIHBhc3NhZ2Ugc3VnZ2VzdHMgdGhhdCB0aGUgc2NpZW50aXN0cyB3ZXJlIHN1cnByaXNlZCBtYWlubHkgYmVjYXVzZQ==', 'base64'), 'UTF8'),
 convert_from(decode('V2hlbiBhIGhvbmV5YmVlIGZpbmRzIGEgZ29vZCBwYXRjaCBvZiBmbG93ZXJzLCBzaGUgZG9lcyBub3Qga2VlcCBpdCB0byBoZXJzZWxmLiBTaGUgZmxpZXMgYmFjayB0byB0aGUgaGl2ZSBhbmQgcGVyZm9ybXMgYSBkYW5jZSBvbiB0aGUgd2FsbCBvZiB0aGUgaG9uZXljb21iLiBJbiB0aGlzICJ3YWdnbGUgZGFuY2UsIiB0aGUgYmVlIHJ1bnMgaW4gYSBzdHJhaWdodCBsaW5lIHdoaWxlIHNoYWtpbmcgaGVyIGJvZHkgZnJvbSBzaWRlIHRvIHNpZGUsIHRoZW4gY2lyY2xlcyBiYWNrIGFuZCByZXBlYXRzIHRoZSBydW4uCgpUaGUgZGFuY2UgaXMgYSBzZXQgb2YgZGlyZWN0aW9ucy4gVGhlIGFuZ2xlIG9mIHRoZSBzdHJhaWdodCBydW4gdGVsbHMgdGhlIG90aGVyIGJlZXMgd2hpY2ggd2F5IHRvIGZseSBjb21wYXJlZCB0byB0aGUgZGlyZWN0aW9uIG9mIHRoZSBzdW4uIFRoZSBsZW5ndGggb2YgdGhlIHJ1biB0ZWxscyB0aGVtIGhvdyBmYXIgYXdheSB0aGUgZmxvd2VycyBhcmU6IHRoZSBsb25nZXIgdGhlIGJlZSB3YWdnbGVzLCB0aGUgZmFydGhlciB0aGUgdHJpcC4gU2NpZW50aXN0cyB3aG8gc3R1ZGllZCB0aGUgZGFuY2Ugd2VyZSBhbWF6ZWQgdGhhdCBhbiBpbnNlY3QgY291bGQgc2hhcmUgc3VjaCBwcmVjaXNlIGluZm9ybWF0aW9uIHdpdGhvdXQgbWFraW5nIGEgc2luZ2xlIHNvdW5kLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJiZWVzIGNhbiBzZWUgdGhlIHN1biBmcm9tIGluc2lkZSB0aGUgaGl2ZSIsICJ0aGUgYmVlcycgbWVzc2FnZSB3YXMgcHJlY2lzZSB5ZXQgY29tcGxldGVseSBzaWxlbnQiLCAiYmVlcyBsaXZlIHRvZ2V0aGVyIGluIGxhcmdlIGdyb3VwcyIsICJmbG93ZXJzIHRlbmQgdG8gZ3JvdyBpbiBwYXRjaGVzIl0=', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('SW5mZXJlbmNlIHF1ZXN0aW9ucyBhc2sgd2hhdCB0aGUgcGFzc2FnZSBpbXBsaWVzLCBidXQgdGhlIHByb29mIGlzIHN0aWxsIGluIHRoZSB0ZXh0LiBUaGUgZmluYWwgc2VudGVuY2UgZ2l2ZXMgdHdvIHJlYXNvbnMgZm9yIHRoZSBhbWF6ZW1lbnQ6IHRoZSBpbmZvcm1hdGlvbiB3YXMgcHJlY2lzZSwgYW5kIGl0IHdhcyBzaGFyZWQgd2l0aG91dCBzb3VuZC4gVGhlIHJpZ2h0IGFuc3dlciBtdXN0IGhvbGQgYm90aCBpZGVhcy4gQ2hvaWNlcyB0aGF0IGFyZSBzaW1wbHkgdHJ1ZSBhYm91dCBiZWVzIGRvIG5vdCBleHBsYWluIHdoeSB0aGUgc2NpZW50aXN0cyB3ZXJlIHN1cnByaXNlZC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGUgcGFzc2FnZSBuZXZlciByYWlzZXMgd2hldGhlciBiZWVzIGNhbiBzZWUgdGhlIHN1biBhcyB0aGUgc3VycHJpc2luZyBwYXJ0LiIsICJDb3JyZWN0LiBUaGUgbGFzdCBzZW50ZW5jZSBzYXlzIHRoZXkgd2VyZSBhbWF6ZWQgYW4gaW5zZWN0IGNvdWxkIHNoYXJlIHN1Y2ggcHJlY2lzZSBpbmZvcm1hdGlvbiB3aXRob3V0IGEgc2luZ2xlIHNvdW5kIOKAlCBwcmVjaXNlIGFuZCBzaWxlbnQgdG9nZXRoZXIuIiwgIkxpdmluZyBpbiBoaXZlcyBpcyBuZXZlciBwcmVzZW50ZWQgYXMgc3VycHJpc2luZy4iLCAiRmxvd2VycyBncm93aW5nIGluIHBhdGNoZXMgaXMgYmFja2dyb3VuZCwgbm90IGEgZGlzY292ZXJ5LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-13', 'reading', 13, convert_from(decode('UmVhZGluZyDigJQgYXV0aG9yJ3MgcHVycG9zZQ==', 'base64'), 'UTF8'),
 convert_from(decode('VGhlIGF1dGhvciBtZW50aW9ucyB0aGUgbmlja25hbWUgIkNsaW50b24ncyBEaXRjaCIgbWFpbmx5IHRv', 'base64'), 'UTF8'),
 convert_from(decode('SW4gMTgxNywgdGhlIHN0YXRlIG9mIE5ldyBZb3JrIGJlZ2FuIGRpZ2dpbmcgYSBjYW5hbCB0aGF0IG1hbnkgcGVvcGxlIHRob3VnaHQgd2FzIGZvb2xpc2guIENyaXRpY3MgY2FsbGVkIGl0ICJDbGludG9uJ3MgRGl0Y2gsIiBhZnRlciBHb3Zlcm5vciBEZVdpdHQgQ2xpbnRvbiwgd2hvIGNoYW1waW9uZWQgdGhlIHBsYW4uIFRoZSBjYW5hbCB3b3VsZCBzdHJldGNoIDM2MyBtaWxlcywgY29ubmVjdGluZyB0aGUgSHVkc29uIFJpdmVyIGF0IEFsYmFueSB0byBMYWtlIEVyaWUgYXQgQnVmZmFsby4KCldoZW4gdGhlIEVyaWUgQ2FuYWwgb3BlbmVkIGluIDE4MjUsIHRoZSBjcml0aWNzIHdlcmUgcHJvdmVkIHdyb25nLiBCZWZvcmUgdGhlIGNhbmFsLCBtb3ZpbmcgZ29vZHMgb3ZlcmxhbmQgZnJvbSBCdWZmYWxvIHRvIE5ldyBZb3JrIENpdHkgY291bGQgdGFrZSB3ZWVrcyBhbmQgY29zdCBhIGZvcnR1bmUuIEJ5IGJvYXQsIHRoZSB0cmlwIGJlY2FtZSBtdWNoIGZhc3RlciwgYW5kIHRoZSBjb3N0IG9mIHNoaXBwaW5nIGRyb3BwZWQgYnkgcm91Z2hseSBuaW5ldHkgcGVyY2VudC4gRmFybSBnb29kcyBmcm9tIHRoZSBNaWR3ZXN0IHBvdXJlZCBlYXN0LCBhbmQgTmV3IFlvcmsgQ2l0eSBncmV3IGludG8gdGhlIGJ1c2llc3QgcG9ydCBpbiB0aGUgbmF0aW9uLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJleHBsYWluIGhvdyB0aGUgY2FuYWwgZ290IGl0cyBvZmZpY2lhbCBuYW1lIiwgInByb3ZlIHRoYXQgdGhlIGdvdmVybm9yIHdhcyB1bnBvcHVsYXIiLCAiZGVzY3JpYmUgaG93IHRoZSBjYW5hbCB3YXMgZHVnIiwgInNob3cgdGhhdCBtYW55IHBlb3BsZSBkb3VidGVkIHRoZSBwcm9qZWN0IGF0IGZpcnN0Il0=', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('UHVycG9zZSBxdWVzdGlvbnMgYXNrIFdIWSB0aGUgYXV0aG9yIGluY2x1ZGVkIHNvbWV0aGluZy4gTG9vayBhdCB3aGF0IGNvbWVzIG5leHQ6IHdoZW4gdGhlIGNhbmFsIG9wZW5lZCBpbiAxODI1LCB0aGUgY3JpdGljcyB3ZXJlIHByb3ZlZCB3cm9uZy4gVGhlIG5pY2tuYW1lIHNldHMgdXAgYSBkb3VidCB0aGF0IHRoZSBwYXNzYWdlIHRoZW4gb3ZlcnR1cm5zLiBCZSBzdXNwaWNpb3VzIG9mIGNob2ljZXMgd2l0aCBzdHJvbmcgd29yZHMgbGlrZSAncHJvdmUnIOKAlCBhdXRob3JzIHJhcmVseSBwcm92ZSBhbnl0aGluZyB3aXRoIG9uZSBkZXRhaWwu', 'base64'), 'UTF8'),
 convert_from(decode('WyJUaGUgb2ZmaWNpYWwgbmFtZSB3YXMgdGhlIEVyaWUgQ2FuYWwuIFRoZSBuaWNrbmFtZSB3YXMgYW4gaW5zdWx0LCBub3QgYSB0aXRsZS4iLCAiVGhlIG5pY2tuYW1lIG1vY2tlZCB0aGUgcGxhbiwgbm90IG5lY2Vzc2FyaWx5IHRoZSBtYW4g4oCUIGFuZCAncHJvdmUnIGlzIGZhciB0b28gc3Ryb25nIGZvciBhIHNpbmdsZSBuaWNrbmFtZS4iLCAiVGhlIG5pY2tuYW1lIHNheXMgbm90aGluZyBhYm91dCBob3cgaXQgd2FzIGJ1aWx0LiIsICJDb3JyZWN0LiBDYWxsaW5nIGl0IGEgZGl0Y2ggbW9ja2VkIHRoZSBwcm9qZWN0LCBhbmQgdGhlIG5leHQgcGFyYWdyYXBoIHNheXMgdGhlIGNyaXRpY3Mgd2VyZSBwcm92ZWQgd3Jvbmcg4oCUIHRoZSBhdXRob3Igc2V0cyB1cCB0aGUgZG91YnQgc28gdGhlIHN1Y2Nlc3MgbGFuZHMgaGFyZGVyLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-14', 'reading', 14, convert_from(decode('UmVhZGluZyDigJQgaG93IGFuIGF1dGhvciBhcmd1ZXM=', 'base64'), 'UTF8'),
 convert_from(decode('SG93IGRvZXMgdGhlIGF1dGhvciByZXNwb25kIHRvIHRoZSBhcmd1bWVudCB0aGF0IHRyZWVzIGFyZSB0b28gZXhwZW5zaXZlPw==', 'base64'), 'UTF8'),
 convert_from(decode('RXZlcnkgY2l0eSBzaG91bGQgcGxhbnQgbW9yZSB0cmVlcyBhbG9uZyBpdHMgc3RyZWV0cy4gT24gYSBzdW1tZXIgYWZ0ZXJub29uLCBhIHNoYWRlZCBzaWRld2FsayBjYW4gYmUgbWFueSBkZWdyZWVzIGNvb2xlciB0aGFuIG9uZSBpbiBmdWxsIHN1biwgYW5kIHRyZWVzIGNvb2wgdGhlIGFpciBhcm91bmQgdGhlbSBhcyB3YXRlciBldmFwb3JhdGVzIGZyb20gdGhlaXIgbGVhdmVzLiBUaGF0IG1hdHRlcnMgdG8gYW55b25lIHdhaXRpbmcgZm9yIGEgYnVzIGluIEp1bHkuCgpUcmVlcyBhbHNvIHNvYWsgdXAgcmFpbndhdGVyIHRoYXQgd291bGQgb3RoZXJ3aXNlIHJ1c2ggaW50byBzdG9ybSBkcmFpbnMgYW5kIGZsb29kIGxvdyBzdHJlZXRzLiBTb21lIHBlb3BsZSBhcmd1ZSB0aGF0IHRyZWVzIGFyZSB0b28gZXhwZW5zaXZlIHRvIHBsYW50IGFuZCBjYXJlIGZvci4gQnV0IGEgeW91bmcgdHJlZSBjb3N0cyBmYXIgbGVzcyB0aGFuIHJlcGFpcmluZyBhIGZsb29kZWQgcm9hZCwgYW5kIGl0IGtlZXBzIHdvcmtpbmcgZm9yIGRlY2FkZXMuIEEgY2l0eSB0aGF0IHBsYW50cyB0cmVlcyB0b2RheSBpcyBub3Qgc3BlbmRpbmcgbW9uZXk7IGl0IGlzIHNhdmluZyBpdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJieSBjb21wYXJpbmcgdGhlIGNvc3Qgb2YgYSB0cmVlIHRvIHRoZSBjb3N0IG9mIGZsb29kIGRhbWFnZSIsICJieSBhZ3JlZWluZyB0aGF0IG1vc3QgY2l0aWVzIGNhbm5vdCBhZmZvcmQgdGhlbSIsICJieSBsaXN0aW5nIHRoZSBwcmljZXMgb2YgZGlmZmVyZW50IGtpbmRzIG9mIHRyZWVzIiwgImJ5IHNheWluZyB0aGUgYXJndW1lbnQgaXMgbm90IHdvcnRoIGRpc2N1c3NpbmciXQ==', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('V2hlbiBhbiBhdXRob3Igd3JpdGVzICdTb21lIHBlb3BsZSBhcmd1ZS4uLicsIHdhdGNoIGZvciB0aGUgJ0J1dCcgdGhhdCBmb2xsb3dzIOKAlCB0aGF0IGlzIHdoZXJlIHRoZSBhdXRob3IgYW5zd2Vycy4gSGVyZSB0aGUgYW5zd2VyIGNvbXBhcmVzIHR3byBjb3N0czogYSB0cmVlIG5vdyBhZ2FpbnN0IGZsb29kIHJlcGFpcnMgbGF0ZXIuIFRoZXNlIHF1ZXN0aW9ucyB0ZXN0IHdoZXRoZXIgeW91IGNhbiBuYW1lIHRoZSBhdXRob3IncyBNT1ZFIOKAlCBjb21wYXJlLCBjb25jZWRlLCBvciBkaXNtaXNzIOKAlCBub3QganVzdCByZXBlYXQgd2hhdCB3YXMgc2FpZC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBUaGUgYXV0aG9yIGFuc3dlcnMgb25lIGNvc3Qgd2l0aCBhIGJpZ2dlciBvbmU6IGEgeW91bmcgdHJlZSBjb3N0cyBmYXIgbGVzcyB0aGFuIHJlcGFpcmluZyBhIGZsb29kZWQgcm9hZC4iLCAiVGhlIGF1dGhvciBtZW50aW9ucyB0aGUgb2JqZWN0aW9uIG9ubHkgdG8gYW5zd2VyIGl0IOKAlCB0aGUgdmVyeSBuZXh0IHdvcmQgaXMgJ0J1dC4nIiwgIk5vIHByaWNlcyBhcHBlYXIgYW55d2hlcmUgaW4gdGhlIHBhc3NhZ2UuIiwgIlRoZSBhdXRob3IgZG9lcyBkaXNjdXNzIGl0LCB3aXRoIGEgZGlyZWN0IGNvdW50ZXItYXJndW1lbnQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-reading-15', 'reading', 15, convert_from(decode('UmVhZGluZyDigJQgZHJhd2luZyBhIGNvbmNsdXNpb24=', 'base64'), 'UTF8'),
 convert_from(decode('V2hpY2ggY29uY2x1c2lvbiBpcyBiZXN0IHN1cHBvcnRlZCBieSB0aGUgcGFzc2FnZT8=', 'base64'), 'UTF8'),
 convert_from(decode('QW4gb2N0b3B1cyBjYW4gY2hhbmdlIGNvbG9yIGluIGxlc3MgdGhhbiBhIHNlY29uZC4gSXRzIHNraW4gaG9sZHMgdGhvdXNhbmRzIG9mIHRpbnkgc2FjcyBvZiBwaWdtZW50IGNhbGxlZCBjaHJvbWF0b3Bob3JlcywgYW5kIGVhY2ggc2FjIGlzIHJpbmdlZCBieSBtdXNjbGVzLiBXaGVuIHRoZSBtdXNjbGVzIHB1bGwsIHRoZSBzYWMgc3RyZXRjaGVzIHdpZGUgYW5kIGl0cyBjb2xvciBzcHJlYWRzIGFjcm9zcyBhIHBhdGNoIG9mIHNraW47IHdoZW4gdGhleSByZWxheCwgdGhlIHNhYyBzaHJpbmtzIHRvIGEgZG90IHRvbyBzbWFsbCB0byBzZWUuCgpCZWNhdXNlIHRoZXNlIG11c2NsZXMgYXJlIGNvbnRyb2xsZWQgYnkgbmVydmVzLCBhbiBvY3RvcHVzIGNhbiByZXNoYXBlIHRoZSBwYXR0ZXJucyBvbiBpdHMgYm9keSBhbG1vc3QgaW5zdGFudGx5LiBJdCB1c2VzIHRoaXMgc2tpbGwgdG8gdmFuaXNoIGFnYWluc3QgYSByb2NreSBzZWFmbG9vciwgdG8gc3RhcnRsZSBhIHByZWRhdG9yIHdpdGggYSBzdWRkZW4gZmxhc2ggb2YgZGFyayBjb2xvciwgb3IgdG8gc2lnbmFsIHRvIG90aGVyIG9jdG9wdXNlcy4gVGhlIHNhbWUgYW5pbWFsIHRoYXQgY2FuIHNxdWVlemUgdGhyb3VnaCBhIGdhcCB0aGUgc2l6ZSBvZiBhIGNvaW4gY2FuIGFsc28gZGlzYXBwZWFyIGluIHBsYWluIHNpZ2h0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJPY3RvcHVzZXMgY2hhbmdlIGNvbG9yIG9ubHkgd2hlbiB0aGV5IGFyZSBmcmlnaHRlbmVkLiIsICJBbGwgc2VhIGFuaW1hbHMgY2FuIGNoYW5nZSBjb2xvciBxdWlja2x5LiIsICJBbiBvY3RvcHVzJ3MgY29sb3IgY2hhbmdlcyBzZXJ2ZSBtb3JlIHRoYW4gb25lIHB1cnBvc2UuIiwgIk9jdG9wdXNlcyBjYW5ub3Qgc2VlIHRoZWlyIHByZWRhdG9ycy4iXQ==', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('U3VwcG9ydGVkIGNvbmNsdXNpb25zIHN0YXkgY2xvc2UgdG8gdGhlIHRleHQuIEFic29sdXRlIHdvcmRzIOKAlCBvbmx5LCBhbGwsIG5ldmVyIOKAlCBhcmUgcmVkIGZsYWdzLCBiZWNhdXNlIG9uZSBjb3VudGVyLWV4YW1wbGUgYnJlYWtzIHRoZW0uIFRoZSBwYXNzYWdlIG5hbWVzIHRocmVlIGRpZmZlcmVudCByZWFzb25zIGZvciBjaGFuZ2luZyBjb2xvciwgd2hpY2ggc3VwcG9ydHMgJ21vcmUgdGhhbiBvbmUgcHVycG9zZScgYW5kIGJyZWFrcyAnb25seSB3aGVuIGZyaWdodGVuZWQuJw==', 'base64'), 'UTF8'),
 convert_from(decode('WyInT25seScgaXMgdG9vIHN0cm9uZy4gVGhlIHBhc3NhZ2UgYWxzbyBsaXN0cyBoaWRpbmcgYW5kIHNpZ25hbGluZyB0byBvdGhlciBvY3RvcHVzZXMuIiwgIlRoZSBwYXNzYWdlIGlzIGFib3V0IG9jdG9wdXNlcyBhbG9uZTsgJ2FsbCBzZWEgYW5pbWFscycgZ29lcyBmYXIgYmV5b25kIGl0LiIsICJDb3JyZWN0LiBUaGUgcGFzc2FnZSBsaXN0cyB0aHJlZSB1c2VzOiBoaWRpbmcgYWdhaW5zdCB0aGUgc2VhZmxvb3IsIHN0YXJ0bGluZyBhIHByZWRhdG9yLCBhbmQgc2lnbmFsaW5nIHRvIG90aGVyIG9jdG9wdXNlcy4iLCAiTm90aGluZyBhYm91dCBvY3RvcHVzIGV5ZXNpZ2h0IGFwcGVhcnMgaW4gdGhlIHBhc3NhZ2UuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-01', 'math', 1, convert_from(decode('T3JkZXIgb2Ygb3BlcmF0aW9ucw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyA2ICsgNCDDlyAzPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIzMCIsICIxOCIsICIxMyIsICIyMiJd', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('TXVsdGlwbGljYXRpb24gYW5kIGRpdmlzaW9uIGNvbWUgYmVmb3JlIGFkZGl0aW9uIGFuZCBzdWJ0cmFjdGlvbiwgdW5sZXNzIHBhcmVudGhlc2VzIHNheSBvdGhlcndpc2UuIFNvIDQgw5cgMyA9IDEyIGZpcnN0LCB0aGVuIDYgKyAxMiA9IDE4LiBSZWFkaW5nIGxlZnQgdG8gcmlnaHQgYW5kIGFkZGluZyA2ICsgNCBmaXJzdCBpcyB0aGUgc2luZ2xlIG1vc3QgY29tbW9uIG1pc3Rha2Ugb24gdGhlc2Uu', 'base64'), 'UTF8'),
 convert_from(decode('WyIzMCBhZGRzIGZpcnN0OiAoNiArIDQpIMOXIDMuIFdpdGhvdXQgcGFyZW50aGVzZXMsIG11bHRpcGxpY2F0aW9uIGNvbWVzIGJlZm9yZSBhZGRpdGlvbi4iLCAiQ29ycmVjdC4gTXVsdGlwbHkgZmlyc3Q6IDQgw5cgMyA9IDEyLiBUaGVuIGFkZDogNiArIDEyID0gMTguIiwgIjEzIGFkZHMgYWxsIHRocmVlIG51bWJlcnMuIFRoZSDDlyBzaWduIG1lYW5zIG11bHRpcGx5LiIsICIyMiBtdWx0aXBsaWVzIDYgw5cgMyBhbmQgdGhlbiBhZGRzIDQg4oCUIHRoZSBvcGVyYXRpb25zIGFyZSBhdHRhY2hlZCB0byB0aGUgd3JvbmcgbnVtYmVycy4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-02', 'math', 2, convert_from(decode('QWRkaW5nIGZyYWN0aW9ucw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyAxLzIgKyAxLzQ/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIyLzYiLCAiMS84IiwgIjMvNCIsICIyLzQiXQ==', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('WW91IGNhbiBvbmx5IGFkZCBmcmFjdGlvbnMgd2hvc2UgYm90dG9tcyAoZGVub21pbmF0b3JzKSBtYXRjaC4gUmV3cml0ZSAxLzIgYXMgMi80LCBzbyBib3RoIGFyZSBpbiBmb3VydGhzLiBUaGVuIGFkZCB0aGUgdG9wczogMi80ICsgMS80ID0gMy80LiBOZXZlciBhZGQgdGhlIGRlbm9taW5hdG9ycyDigJQgb25lIGZvdXJ0aCBwbHVzIG9uZSBmb3VydGggaXMgdHdvIGZvdXJ0aHMsIG5vdCB0d28gZWlnaHRocy4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIyLzYgYWRkcyB0aGUgdG9wcyBhbmQgdGhlIGJvdHRvbXMgc2VwYXJhdGVseS4gRnJhY3Rpb25zIG5lZWQgYSBjb21tb24gZGVub21pbmF0b3IgYmVmb3JlIHlvdSBhZGQuIiwgIjEvOCBpcyAxLzIgw5cgMS80IOKAlCB0aGF0IG11bHRpcGxpZXMgaW5zdGVhZCBvZiBhZGRpbmcuIiwgIkNvcnJlY3QuIDEvMiBpcyB0aGUgc2FtZSBhcyAyLzQsIGFuZCAyLzQgKyAxLzQgPSAzLzQuIiwgIjIvNCBpcyBqdXN0IDEvMiByZXdyaXR0ZW4uIFlvdSBzdGlsbCBuZWVkIHRvIGFkZCB0aGUgMS80LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-03', 'math', 3, convert_from(decode('UGVyY2VudHM=', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyAxMCUgb2YgMjUwPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIyLjUiLCAiMjQwIiwgIjEwIiwgIjI1Il0=', 'base64'), 'UTF8')::JSONB, 3, 1,
 convert_from(decode('MTAlIGlzIG9uZSB0ZW50aCwgc28gZGl2aWRlIGJ5IDEwIOKAlCB3aGljaCBqdXN0IG1vdmVzIHRoZSBkZWNpbWFsIHBvaW50IG9uZSBwbGFjZSBsZWZ0OiAyNTAgYmVjb21lcyAyNS4wLiBLbm93aW5nIDEwJSBpbnN0YW50bHkgbGV0cyB5b3UgYnVpbGQgb3RoZXJzOiAyMCUgaXMgZG91YmxlICg1MCksIGFuZCA1JSBpcyBoYWxmICgxMi41KS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIyLjUgaXMgMSUgb2YgMjUwIOKAlCB0aGUgZGVjaW1hbCBtb3ZlZCBvbmUgcGxhY2UgdG9vIGZhci4iLCAiMjQwIHN1YnRyYWN0cyAxMCBmcm9tIDI1MC4gQSBwZXJjZW50IG1lYW5zIGEgcGFydCBvdXQgb2YgMTAwLCBub3QgYSBudW1iZXIgdG8gc3VidHJhY3QuIiwgIjEwIGlzIHRoZSBwZXJjZW50IGl0c2VsZiwgbm90IDEwJSBvZiAyNTAuIiwgIkNvcnJlY3QuIDEwJSBtZWFucyBvbmUgdGVudGg6IDI1MCDDtyAxMCA9IDI1LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-04', 'math', 4, convert_from(decode('UGVyaW1ldGVy', 'base64'), 'UTF8'),
 convert_from(decode('QSByZWN0YW5nbGUgaXMgNyBpbmNoZXMgbG9uZyBhbmQgMyBpbmNoZXMgd2lkZS4gV2hhdCBpcyBpdHMgcGVyaW1ldGVyPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIyMCBpbmNoZXMiLCAiMjEgaW5jaGVzIiwgIjEwIGluY2hlcyIsICIxNyBpbmNoZXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('UGVyaW1ldGVyIG1lYW5zIHRoZSBkaXN0YW5jZSBhcm91bmQgdGhlIG91dHNpZGUuIEEgcmVjdGFuZ2xlIGhhcyB0d28gbGVuZ3RocyBhbmQgdHdvIHdpZHRoczogNyArIDcgKyAzICsgMyA9IDIwLiBUaGUgcXVpY2sgd2F5IGlzIDIgw5cgKDcgKyAzKS4gSWYgeW91IG11bHRpcGxpZWQgNyDDlyAzLCB5b3UgZm91bmQgdGhlIGFyZWEg4oCUIGEgY29tcGxldGVseSBkaWZmZXJlbnQgbWVhc3VyZW1lbnQu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBQZXJpbWV0ZXIgaXMgdGhlIGRpc3RhbmNlIGFsbCB0aGUgd2F5IGFyb3VuZDogNyArIDMgKyA3ICsgMyA9IDIwLiIsICIyMSBpcyA3IMOXIDMsIHdoaWNoIGlzIHRoZSBBUkVBLiBQZXJpbWV0ZXIgYWRkcyB0aGUgc2lkZXM7IGFyZWEgbXVsdGlwbGllcyB0aGVtLiIsICIxMCBhZGRzIG9uZSBsZW5ndGggYW5kIG9uZSB3aWR0aCDigJQgb25seSBoYWxmd2F5IGFyb3VuZC4iLCAiMTcgY291bnRzIG9ubHkgdGhyZWUgc2lkZXM6IDcgKyA3ICsgMy4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-05', 'math', 5, convert_from(decode('V29yZCBwcm9ibGVtcyDigJQgbXVsdGlwbHlpbmc=', 'base64'), 'UTF8'),
 convert_from(decode('Tm90ZWJvb2tzIGNvc3QgJDIuNTAgZWFjaC4gSG93IG11Y2ggZG8gMyBub3RlYm9va3MgY29zdD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIkNS4wMCIsICIkNS41MCIsICIkNi41MCIsICIkNy41MCJd', 'base64'), 'UTF8')::JSONB, 3, 1,
 convert_from(decode('VGhlIHdvcmQgJ2VhY2gnIHNpZ25hbHMgbXVsdGlwbGljYXRpb246IHByaWNlIHBlciBpdGVtIHRpbWVzIHRoZSBudW1iZXIgb2YgaXRlbXMuIEZvciAzIMOXICQyLjUwLCBzcGxpdCBkb2xsYXJzIGZyb20gY2VudHM6IDMgw5cgMiA9IDYgYW5kIDMgw5cgMC41MCA9IDEuNTAsIHNvIDYgKyAxLjUwID0gJDcuNTAuIFNwbGl0dGluZyBsaWtlIHRoaXMgbWFrZXMgbW9uZXkgbWF0aCBlYXN5IHRvIGRvIGluIHlvdXIgaGVhZC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIkNS4wMCBpcyB0aGUgY29zdCBvZiAyIG5vdGVib29rcywgbm90IDMuIiwgIiQ1LjUwIGFkZHMgJDMgdG8gJDIuNTAg4oCUIGl0IGFkZHMgdGhlIGNvdW50IGluc3RlYWQgb2YgbXVsdGlwbHlpbmcgYnkgaXQuIiwgIiQ2LjUwIGlzIGEgZG9sbGFyIHNob3J0LiBDaGVjayBieSBhZGRpbmcgJDIuNTAgdGhyZWUgdGltZXM6ICQyLjUwLCAkNS4wMCwgJDcuNTAuIiwgIkNvcnJlY3QuIDMgw5cgJDIuNTAgPSAkNy41MC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-06', 'math', 6, convert_from(decode('T3JkZXIgb2Ygb3BlcmF0aW9ucw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyAoOCDiiJIgMynCsiDiiJIgNCDDlyAyPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyI0MiIsICI0NyIsICIxNyIsICIyIl0=', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('VGhlIG9yZGVyIGlzIFBhcmVudGhlc2VzLCBFeHBvbmVudHMsIE11bHRpcGxpY2F0aW9uIGFuZCBEaXZpc2lvbiwgdGhlbiBBZGRpdGlvbiBhbmQgU3VidHJhY3Rpb24uICg4IOKIkiAzKSA9IDU7IDXCsiA9IDI1OyA0IMOXIDIgPSA4OyAyNSDiiJIgOCA9IDE3LiBUaGUgZXhwb25lbnQgc2l0cyBvdXRzaWRlIHRoZSBwYXJlbnRoZXNlcywgc28gaXQgc3F1YXJlcyB0aGUgcmVzdWx0LCA1IOKAlCBub3QgdGhlIDggYW5kIHRoZSAzIHNlcGFyYXRlbHku', 'base64'), 'UTF8'),
 convert_from(decode('WyI0MiBzdWJ0cmFjdHMgNCBmcm9tIDI1IGJlZm9yZSBtdWx0aXBseWluZy4gVGhlIG11bHRpcGxpY2F0aW9uLCA0IMOXIDIsIG11c3QgY29tZSBmaXJzdC4iLCAiNDcgc3F1YXJlcyA4IGFuZCAzIHNlcGFyYXRlbHkgKDY0IOKIkiA5IOKIkiA4KS4gVGhlIGV4cG9uZW50IGFwcGxpZXMgdG8gdGhlIHdob2xlIHBhcmVudGhlc2VzLCB3aGljaCBlcXVhbCA1LiIsICJDb3JyZWN0LiBQYXJlbnRoZXNlcyBmaXJzdDogOCDiiJIgMyA9IDUuIEV4cG9uZW50OiA1wrIgPSAyNS4gTXVsdGlwbHk6IDQgw5cgMiA9IDguIFN1YnRyYWN0OiAyNSDiiJIgOCA9IDE3LiIsICIyIHRyZWF0cyB0aGUgc21hbGwgMiBhcyDDlyAyOiA1IMOXIDIgPSAxMCwgdGhlbiAxMCDiiJIgOC4gVGhlIMKyIG1lYW5zIG11bHRpcGx5IDUgYnkgSVRTRUxGLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-07', 'math', 7, convert_from(decode('RnJhY3Rpb25zIG9mIGEgbnVtYmVy', 'base64'), 'UTF8'),
 convert_from(decode('V2hhdCBpcyAyLzMgb2YgNDU/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxNSIsICIzMCIsICIyMi41IiwgIjY3LjUiXQ==', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('J09mJyBtZWFucyBtdWx0aXBseS4gVGhlIGVhc3kgd2F5OiBkaXZpZGUgYnkgdGhlIGJvdHRvbSBudW1iZXIsIG11bHRpcGx5IGJ5IHRoZSB0b3AuIDQ1IMO3IDMgPSAxNSwgdGhlbiAxNSDDlyAyID0gMzAuIEEgcXVpY2sgc2FuaXR5IGNoZWNrOiAyLzMgaXMgbGVzcyB0aGFuIDEsIHNvIHRoZSBhbnN3ZXIgbXVzdCBiZSBsZXNzIHRoYW4gNDUu', 'base64'), 'UTF8'),
 convert_from(decode('WyIxNSBpcyBvbmUgdGhpcmQgb2YgNDUuIFR3byB0aGlyZHMgaXMgdHdpY2UgdGhhdC4iLCAiQ29ycmVjdC4gT25lIHRoaXJkIG9mIDQ1IGlzIDE1LCBzbyB0d28gdGhpcmRzIGlzIDMwLiIsICIyMi41IGlzIG9uZSBoYWxmIG9mIDQ1LiBUd28gdGhpcmRzIGlzIG1vcmUgdGhhbiBhIGhhbGYuIiwgIjY3LjUgZmxpcHMgdGhlIGZyYWN0aW9uICg0NSDDlyAzLzIpLiBUYWtpbmcgMi8zIG9mIGEgbnVtYmVyIG1ha2VzIGl0IHNtYWxsZXIsIG5vdCBiaWdnZXIuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-08', 'math', 8, convert_from(decode('U29sdmluZyBlcXVhdGlvbnM=', 'base64'), 'UTF8'),
 convert_from(decode('SWYgM3ggKyA1ID0gMjAsIHdoYXQgaXMgeD8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxNSIsICIyNS8zIiwgIjUiLCAiNDUiXQ==', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('VW5kbyB0aGUgb3BlcmF0aW9ucyBpbiByZXZlcnNlIG9yZGVyLCBkb2luZyB0aGUgc2FtZSB0aGluZyB0byBib3RoIHNpZGVzLiBUaGUgKyA1IGhhcHBlbmVkIGxhc3QsIHNvIHJlbW92ZSBpdCBmaXJzdDogM3ggPSAxNS4gVGhlbiB1bmRvIHRoZSDDlyAzIGJ5IGRpdmlkaW5nOiB4ID0gNS4gQWx3YXlzIHBsdWcgeW91ciBhbnN3ZXIgYmFjayBpbiB0byBjaGVjayBpdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyIxNSBpcyAzeCDigJQgb25lIHN0ZXAgc2hvcnQuIERpdmlkZSBieSAzIHRvIGZpbmQgeCBpdHNlbGYuIiwgIjI1LzMgY29tZXMgZnJvbSBhZGRpbmcgNSBpbnN0ZWFkIG9mIHN1YnRyYWN0aW5nIGl0LiBUbyB1bmRvICsgNSwgc3VidHJhY3QgNS4iLCAiQ29ycmVjdC4gU3VidHJhY3QgNSBmcm9tIGJvdGggc2lkZXM6IDN4ID0gMTUuIERpdmlkZSBieSAzOiB4ID0gNS4gQ2hlY2s6IDMgw5cgNSArIDUgPSAyMC4iLCAiNDUgbXVsdGlwbGllcyAxNSBieSAzIGluc3RlYWQgb2YgZGl2aWRpbmcuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-09', 'math', 9, convert_from(decode('QXJlYQ==', 'base64'), 'UTF8'),
 convert_from(decode('QSB0cmlhbmdsZSBoYXMgYSBiYXNlIG9mIDEwIGNtIGFuZCBhIGhlaWdodCBvZiA2IGNtLiBXaGF0IGlzIGl0cyBhcmVhPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxNiBjbcKyIiwgIjYwIGNtwrIiLCAiMzAgY23CsiIsICI4IGNtwrIiXQ==', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('QSB0cmlhbmdsZSBpcyBleGFjdGx5IGhhbGYgb2YgYSByZWN0YW5nbGUgd2l0aCB0aGUgc2FtZSBiYXNlIGFuZCBoZWlnaHQuIFNvIGZpbmQgYmFzZSDDlyBoZWlnaHQgKDEwIMOXIDYgPSA2MCkgYW5kIGhhbHZlIGl0OiAzMC4gVGhlIHVuaXRzIGFyZSBzcXVhcmVkIOKAlCBjbcKyIOKAlCBiZWNhdXNlIHlvdSBtdWx0aXBsaWVkIHR3byBsZW5ndGhzIHRvZ2V0aGVyLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyIxNiBhZGRzIHRoZSBiYXNlIGFuZCB0aGUgaGVpZ2h0LiBBcmVhIG11bHRpcGxpZXMgdGhlbS4iLCAiNjAgaXMgYmFzZSDDlyBoZWlnaHQg4oCUIHRoZSBhcmVhIG9mIGEgUkVDVEFOR0xFLiBBIHRyaWFuZ2xlIGlzIGhhbGYgb2YgdGhhdC4iLCAiQ29ycmVjdC4gQXJlYSA9IMK9IMOXIGJhc2Ugw5cgaGVpZ2h0ID0gwr0gw5cgMTAgw5cgNiA9IDMwIGNtwrIuIiwgIjggaGFsdmVzIHRoZSBzdW0gb2YgYmFzZSBhbmQgaGVpZ2h0IGluc3RlYWQgb2YgdGhlaXIgcHJvZHVjdC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-10', 'math', 10, convert_from(decode('UGVyY2VudCBkaXNjb3VudHM=', 'base64'), 'UTF8'),
 convert_from(decode('QSBzaGlydCBjb3N0cyAkNDAuIEl0IGlzIG9uIHNhbGUgZm9yIDI1JSBvZmYuIFdoYXQgaXMgdGhlIHNhbGUgcHJpY2U/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIkMzAiLCAiJDEwIiwgIiQxNSIsICIkNTAiXQ==', 'base64'), 'UTF8')::JSONB, 0, 2,
 convert_from(decode('VHdvIHN0ZXBzOiBmaW5kIHRoZSBkaXNjb3VudCwgdGhlbiBzdWJ0cmFjdCBpdC4gMjUlIGlzIG9uZSBxdWFydGVyLCBhbmQgYSBxdWFydGVyIG9mICQ0MCBpcyAkMTAuIFRoZSBzYWxlIHByaWNlIGlzICQ0MCDiiJIgJDEwID0gJDMwLiBTaG9ydGN1dDogMjUlIG9mZiBtZWFucyB5b3UgcGF5IDc1JSwgYW5kIDc1JSBvZiAkNDAgaXMgJDMwLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiAyNSUgb2YgJDQwIGlzICQxMCwgYW5kICQ0MCDiiJIgJDEwID0gJDMwLiIsICIkMTAgaXMgdGhlIGFtb3VudCB5b3UgU0FWRSwgMjUlIG9mICQ0MC4gVGhlIHNhbGUgcHJpY2UgaXMgd2hhdCBpcyBsZWZ0IHRvIHBheS4iLCAiJDE1IHN1YnRyYWN0cyAyNSBkb2xsYXJzLCB0cmVhdGluZyB0aGUgcGVyY2VudCBhcyBpZiBpdCB3ZXJlIG1vbmV5LiIsICIkNTAgYWRkcyB0aGUgZGlzY291bnQuIEEgc2FsZSBsb3dlcnMgdGhlIHByaWNlLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-11', 'math', 11, convert_from(decode('UmF0aW9z', 'base64'), 'UTF8'),
 convert_from(decode('VGhlIHJhdGlvIG9mIGJveXMgdG8gZ2lybHMgaW4gYSBjbGFzcyBpcyAzIHRvIDUuIElmIHRoZXJlIGFyZSA0MCBzdHVkZW50cyBpbiB0aGUgY2xhc3MsIGhvdyBtYW55IGFyZSBnaXJscz8=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIxNSIsICIyNSIsICIyNCIsICI1Il0=', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('QSByYXRpbyBvZiAzIHRvIDUgc3BsaXRzIHRoZSBjbGFzcyBpbnRvIDMgKyA1ID0gOCBlcXVhbCBwYXJ0cy4gRmluZCBvbmUgcGFydDogNDAgw7cgOCA9IDUgc3R1ZGVudHMuIFRoZSBnaXJscyBhcmUgNSBwYXJ0cywgc28gMjUuIENoZWNrIHdpdGggdGhlIGJveXM6IDMgcGFydHMgaXMgMTUsIGFuZCAxNSArIDI1ID0gNDAu', 'base64'), 'UTF8'),
 convert_from(decode('WyIxNSBpcyB0aGUgbnVtYmVyIG9mIEJPWVMgKDMgcGFydHMgb2YgNSBzdHVkZW50cyBlYWNoKS4gVGhlIHF1ZXN0aW9uIGFza3MgZm9yIGdpcmxzLiIsICJDb3JyZWN0LiAzICsgNSA9IDggZXF1YWwgcGFydHMsIGFuZCA0MCDDtyA4ID0gNSBzdHVkZW50cyBwZXIgcGFydC4gR2lybHMgZ2V0IDUgcGFydHM6IDUgw5cgNSA9IDI1LiIsICIyNCB0YWtlcyAzLzUgb2YgdGhlIHdob2xlIGNsYXNzLiBCdXQgdGhlIHJhdGlvIGNvbXBhcmVzIGJveXMgdG8gZ2lybHMsIG5vdCBib3lzIHRvIGFsbCA0MCBzdHVkZW50cy4iLCAiNSBpcyB0aGUgc2l6ZSBvZiBPTkUgcGFydC4gVGhlIGdpcmxzIGFyZSBmaXZlIHBhcnRzLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-12', 'math', 12, convert_from(decode('U29sdmluZyBlcXVhdGlvbnMg4oCUIHggb24gYm90aCBzaWRlcw==', 'base64'), 'UTF8'),
 convert_from(decode('SWYgMih4IOKIkiAzKSA9IHggKyA0LCB3aGF0IGlzIHg/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyI3IiwgIuKIkjIiLCAiMTAvMyIsICIxMCJd', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('Rmlyc3QgY2xlYXIgdGhlIHBhcmVudGhlc2VzIGJ5IG11bHRpcGx5aW5nIHRoZSAyIGJ5IEJPVEggdGVybXMgaW5zaWRlOiAyeCDiiJIgNi4gVGhlbiBnYXRoZXIgdGhlIHgncyBvbiBvbmUgc2lkZSBieSBzdWJ0cmFjdGluZyB4IGZyb20gYm90aCBzaWRlczogeCDiiJIgNiA9IDQuIFVuZG8gdGhlIOKIkiA2IGJ5IGFkZGluZyA2OiB4ID0gMTAuIENoZWNrIGluIHRoZSBvcmlnaW5hbDogMigxMCDiiJIgMykgPSAxNCwgYW5kIDEwICsgNCA9IDE0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyI3IGZvcmdldHMgdG8gbXVsdGlwbHkgdGhlIDMgYnkgMi4gMih4IOKIkiAzKSBpcyAyeCDiiJIgNiwgbm90IDJ4IOKIkiAzLiIsICLiiJIyIHN1YnRyYWN0cyA2IHdoZW4gbW92aW5nIGl0IGFjcm9zcy4gVG8gdW5kbyDiiJIgNiwgYWRkIDYuIiwgIjEwLzMgYWRkcyB4IHRvIGJvdGggc2lkZXMsIGdpdmluZyAzeCA9IDEwLiBUbyBnYXRoZXIgdGhlIHgncyBvbiBvbmUgc2lkZSwgc3VidHJhY3QgeC4iLCAiQ29ycmVjdC4gRGlzdHJpYnV0ZTogMngg4oiSIDYgPSB4ICsgNC4gU3VidHJhY3QgeCBmcm9tIGJvdGggc2lkZXM6IHgg4oiSIDYgPSA0LiBBZGQgNjogeCA9IDEwLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-13', 'math', 13, convert_from(decode('Q2lyY2xlcw==', 'base64'), 'UTF8'),
 convert_from(decode('QSBjaXJjbGUgaGFzIGEgZGlhbWV0ZXIgb2YgMTAgaW5jaGVzLiBXaGF0IGlzIGl0cyBhcmVhPyAoVXNlIM+AIOKJiCAzLjE0KQ==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIzMTQgc3F1YXJlIGluY2hlcyIsICI3OC41IHNxdWFyZSBpbmNoZXMiLCAiMzEuNCBzcXVhcmUgaW5jaGVzIiwgIjE1Ljcgc3F1YXJlIGluY2hlcyJd', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('QXJlYSBvZiBhIGNpcmNsZSA9IM+AIMOXIHLCsiwgd2hlcmUgciBpcyB0aGUgcmFkaXVzLiBUaGUgcHJvYmxlbSBnaXZlcyB0aGUgZGlhbWV0ZXIsIHNvIGhhbHZlIGl0IGZpcnN0OiByID0gNS4gVGhlbiA1wrIgPSAyNSwgYW5kIDMuMTQgw5cgMjUgPSA3OC41LiBUaGUgdHdvIGNsYXNzaWMgdHJhcHMgYXJlIHVzaW5nIHRoZSBkaWFtZXRlciBpbnN0ZWFkIG9mIHRoZSByYWRpdXMsIGFuZCBjb25mdXNpbmcgYXJlYSB3aXRoIGNpcmN1bWZlcmVuY2UsIHdoaWNoIGlzIM+AIMOXIGQu', 'base64'), 'UTF8'),
 convert_from(decode('WyIzMTQgdXNlcyB0aGUgZGlhbWV0ZXIgYXMgdGhlIHJhZGl1czogMy4xNCDDlyAxMMKyLiBUaGUgcmFkaXVzIGlzIGhhbGYgdGhlIGRpYW1ldGVyLiIsICJDb3JyZWN0LiBUaGUgcmFkaXVzIGlzIDEwIMO3IDIgPSA1LiBBcmVhID0gz4Agw5cgcsKyID0gMy4xNCDDlyAyNSA9IDc4LjUgc3F1YXJlIGluY2hlcy4iLCAiMzEuNCBpcyB0aGUgQ0lSQ1VNRkVSRU5DRSAoz4Agw5cgZGlhbWV0ZXIpIOKAlCB0aGUgZGlzdGFuY2UgYXJvdW5kLCBub3QgdGhlIHNwYWNlIGluc2lkZS4iLCAiMTUuNyBpcyDPgCDDlyA1LiBJdCBtdWx0aXBsaWVzIGJ5IHRoZSByYWRpdXMgb25jZSBpbnN0ZWFkIG9mIHNxdWFyaW5nIGl0LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-14', 'math', 14, convert_from(decode('QXZlcmFnZXMg4oCUIGZpbmRpbmcgYSBtaXNzaW5nIHNjb3Jl', 'base64'), 'UTF8'),
 convert_from(decode('SmFkYSdzIGZpcnN0IHRocmVlIHRlc3Qgc2NvcmVzIGFyZSA4MCwgODUsIGFuZCA5MC4gV2hhdCBzY29yZSBkb2VzIHNoZSBuZWVkIG9uIHRoZSBmb3VydGggdGVzdCB0byBoYXZlIGFuIGF2ZXJhZ2Ugb2YgODY/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyI4NSIsICI4NiIsICI5MSIsICI4OSJd', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('V29yayB3aXRoIHRvdGFscywgbm90IGF2ZXJhZ2VzLiBUbyBhdmVyYWdlIDg2IG92ZXIgNCB0ZXN0cywgdGhlIGZvdXIgc2NvcmVzIG11c3QgYWRkIHVwIHRvIDQgw5cgODYgPSAzNDQuIFNoZSBhbHJlYWR5IGhhcyAyNTUuIFRoZSBkaWZmZXJlbmNlIGlzIHdoYXQgc2hlIG5lZWRzOiAzNDQg4oiSIDI1NSA9IDg5LiBDaGVjazogKDgwICsgODUgKyA5MCArIDg5KSDDtyA0ID0gMzQ0IMO3IDQgPSA4Ni4=', 'base64'), 'UTF8'),
 convert_from(decode('WyI4NSBpcyBoZXIgQ1VSUkVOVCBhdmVyYWdlICgyNTUgw7cgMykuIFRoZSBxdWVzdGlvbiBhc2tzIHdoYXQgc2hlIG5lZWRzIG5leHQuIiwgIlNjb3JpbmcgZXhhY3RseSA4NiB3b3VsZCBvbmx5IGxpZnQgaGVyIGF2ZXJhZ2UgdG8gODUuMjUsIGJlY2F1c2UgaGVyIGZpcnN0IHRocmVlIHRlc3RzIGF2ZXJhZ2UgYmVsb3cgODYuIiwgIjkxIG92ZXJzaG9vdHM6ICgyNTUgKyA5MSkgw7cgNCA9IDg2LjUuIiwgIkNvcnJlY3QuIEFuIGF2ZXJhZ2Ugb2YgODYgb3ZlciA0IHRlc3RzIG5lZWRzIGEgdG90YWwgb2YgNCDDlyA4NiA9IDM0NC4gU2hlIGhhcyA4MCArIDg1ICsgOTAgPSAyNTUsIHNvIHNoZSBuZWVkcyAzNDQg4oiSIDI1NSA9IDg5LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-math-15', 'math', 15, convert_from(decode('UmF0ZXM=', 'base64'), 'UTF8'),
 convert_from(decode('QSBjYXIgdHJhdmVscyAxODAgbWlsZXMgaW4gMyBob3Vycy4gQXQgdGhlIHNhbWUgcmF0ZSwgaG93IGZhciB3aWxsIGl0IHRyYXZlbCBpbiA1IGhvdXJzPw==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyIzMDAgbWlsZXMiLCAiMTA4IG1pbGVzIiwgIjkwMCBtaWxlcyIsICIzNjAgbWlsZXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('RmluZCB0aGUgdW5pdCByYXRlIGZpcnN0IOKAlCBtaWxlcyBpbiBPTkUgaG91cjogMTgwIMO3IDMgPSA2MC4gVGhlbiBzY2FsZSB1cDogNjAgw5cgNSA9IDMwMC4gU2FuaXR5IGNoZWNrOiA1IGhvdXJzIGlzIGxvbmdlciB0aGFuIDMsIHNvIHRoZSBhbnN3ZXIgbXVzdCBiZSBtb3JlIHRoYW4gMTgwLCBhbmQgbGVzcyB0aGFuIDM2MCwgc2luY2UgNSBob3VycyBpcyBsZXNzIHRoYW4gZG91YmxlIDMu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiAxODAgw7cgMyA9IDYwIG1pbGVzIHBlciBob3VyLCBhbmQgNjAgw5cgNSA9IDMwMCBtaWxlcy4iLCAiMTA4IGZsaXBzIHRoZSByYXRlICgxODAgw5cgMyDDtyA1KS4gQSBsb25nZXIgdHJpcCBhdCB0aGUgc2FtZSBzcGVlZCBtdXN0IGNvdmVyIE1PUkUgZGlzdGFuY2UsIG5vdCBsZXNzLiIsICI5MDAgbXVsdGlwbGllcyB0aGUgd2hvbGUgMy1ob3VyIGRpc3RhbmNlIGJ5IDUsIGFzIGlmIGV2ZXJ5IGhvdXIgY292ZXJlZCAxODAgbWlsZXMuIiwgIjM2MCBkb3VibGVzIHRoZSBkaXN0YW5jZSwgd2hpY2ggd291bGQgdGFrZSA2IGhvdXJzLCBub3QgNS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-01', 'language', 1, convert_from(decode('Q2FwaXRhbGl6YXRpb24g4oCUIHN0YXJ0aW5nIGEgc2VudGVuY2U=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIGNhcGl0YWxpemF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJNeSBjb3VzaW4gbGl2ZXMgaW4gRGVudmVyLiIsICJ3ZSB2aXNpdGVkIHRoZSBtdXNldW0gb24gU2F0dXJkYXkuIiwgIlRoZSBQYWNpZmljIE9jZWFuIGlzIHZlcnkgZGVlcC4iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 1, 1,
 convert_from(decode('Q2hlY2sgZXZlcnkgc2VudGVuY2UgYWdhaW5zdCB0aGUgdHdvIGJhc2ljIHJ1bGVzOiBjYXBpdGFsaXplIHRoZSBmaXJzdCB3b3JkIG9mIGEgc2VudGVuY2UsIGFuZCBjYXBpdGFsaXplIHRoZSBuYW1lcyBvZiBzcGVjaWZpYyBwZW9wbGUsIHBsYWNlcywgYW5kIHRoaW5ncy4gVGhlIG11c2V1bSBzZW50ZW5jZSBzdGFydHMgd2l0aCBhIGxvd2VyY2FzZSAnd2UuJyBDaGVjayB0aGUgZmlyc3QgbGV0dGVyIG9mIGVhY2ggc2VudGVuY2UgZmlyc3Qg4oCUIGl0IGlzIHRoZSBlYXNpZXN0IGVycm9yIHRvIG1pc3MsIGJlY2F1c2UgeW91ciBleWVzIGp1bXAgdG8gdGhlIG1pZGRsZS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyJEZW52ZXIgaXMgYSBjaXR5LCBzbyBpdCBpcyBjYXBpdGFsaXplZCBjb3JyZWN0bHkuIiwgIkNvcnJlY3QuIFRoZSBmaXJzdCB3b3JkIG9mIGV2ZXJ5IHNlbnRlbmNlIG5lZWRzIGEgY2FwaXRhbCBsZXR0ZXI6IFdlIHZpc2l0ZWQgdGhlIG11c2V1bS4iLCAiUGFjaWZpYyBPY2VhbiBpcyB0aGUgbmFtZSBvZiBhIHNwZWNpZmljIG9jZWFuLCBzbyBib3RoIHdvcmRzIGFyZSBjYXBpdGFsaXplZCBjb3JyZWN0bHkuIiwgIlRoZSBtdXNldW0gc2VudGVuY2Ugc3RhcnRzIHdpdGggYSBsb3dlcmNhc2UgbGV0dGVyLCBzbyB0aGVyZSBpcyBhIG1pc3Rha2UuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-02', 'language', 2, convert_from(decode('Q29tbWFzIGluIGEgbGlzdA==', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHB1bmN0dWF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJJIGJvdWdodCBhcHBsZXMgYmFuYW5hcywgYW5kIGdyYXBlcy4iLCAiT3VyIHRlYW0gd29uIHRoZSBnYW1lLiIsICJXaGVyZSBkaWQgeW91IHB1dCB0aGUga2V5cz8iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('V2hlbiB0aHJlZSBvciBtb3JlIGl0ZW1zIGFyZSBsaXN0ZWQsIHNlcGFyYXRlIGVhY2ggb25lIHdpdGggYSBjb21tYS4gJ0FwcGxlcyBiYW5hbmFzJyBydW5zIHR3byBpdGVtcyB0b2dldGhlciB3aXRoIG5vdGhpbmcgYmV0d2VlbiB0aGVtLiBSZWFkIGxpc3RzIHNsb3dseSBhbmQgY2hlY2sgdGhhdCBldmVyeSBpdGVtIGlzIHNlcGFyYXRlZCBmcm9tIHRoZSBuZXh0Lg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBJdGVtcyBpbiBhIGxpc3QgbmVlZCBjb21tYXMgYmV0d2VlbiB0aGVtOiBhcHBsZXMsIGJhbmFuYXMsIGFuZCBncmFwZXMuIEhlcmUgdGhlcmUgaXMgbm8gY29tbWEgYmV0d2VlbiB0aGUgZmlyc3QgdHdvLiIsICJBIGNvbXBsZXRlIHN0YXRlbWVudCB0aGF0IGVuZHMgd2l0aCBhIHBlcmlvZCDigJQgY29ycmVjdC4iLCAiQSBxdWVzdGlvbiB0aGF0IGVuZHMgd2l0aCBhIHF1ZXN0aW9uIG1hcmsg4oCUIGNvcnJlY3QuIiwgIlRoZSBmcnVpdCBzZW50ZW5jZSBpcyBtaXNzaW5nIGEgY29tbWEsIHNvIHRoZXJlIGlzIGEgbWlzdGFrZS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-03', 'language', 3, convert_from(decode('U3ViamVjdOKAk3ZlcmIgYWdyZWVtZW50', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHVzYWdlLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJTaGUgd2Fsa3MgdG8gc2Nob29sIGV2ZXJ5IGRheS4iLCAiVGhleSBhcmUgZ29pbmcgdG8gdGhlIHBhcmsuIiwgIlRoZSBkb2dzIGJhcmtzIGF0IHRoZSBtYWlsIGNhcnJpZXIuIiwgIk5vIG1pc3Rha2VzIl0=', 'base64'), 'UTF8')::JSONB, 2, 1,
 convert_from(decode('QSBzaW5ndWxhciBzdWJqZWN0IHRha2VzIGEgc2luZ3VsYXIgdmVyYiwgYW5kIGEgcGx1cmFsIHN1YmplY3QgdGFrZXMgYSBwbHVyYWwgdmVyYi4gVGhlIGNvbmZ1c2luZyBwYXJ0OiBpbiBFbmdsaXNoIHRoZSBzaW5ndWxhciBWRVJCIGlzIHRoZSBvbmUgZW5kaW5nIGluIC1zIChzaGUgd2Fsa3MpLCB3aGlsZSB0aGUgcGx1cmFsIE5PVU4gZW5kcyBpbiAtcyAoZG9ncykuIFNvIGl0IGlzICd0aGUgZG9ncyBiYXJrJyBidXQgJ3RoZSBkb2cgYmFya3MuJyBGaW5kIHRoZSBzdWJqZWN0LCBkZWNpZGUgd2hldGhlciBpdCBpcyBvbmUgb3IgbWFueSwgdGhlbiBjaGVjayB0aGUgdmVyYi4=', 'base64'), 'UTF8'),
 convert_from(decode('WyInU2hlJyBpcyBvbmUgcGVyc29uLCBhbmQgJ3dhbGtzJyBpcyB0aGUgc2luZ3VsYXIgdmVyYiwgc28gdGhleSBhZ3JlZS4iLCAiJ1RoZXknIGlzIHBsdXJhbCwgYW5kICdhcmUnIGlzIHRoZSBwbHVyYWwgdmVyYiwgc28gdGhleSBhZ3JlZS4iLCAiQ29ycmVjdC4gJ0RvZ3MnIGlzIHBsdXJhbCwgc28gdGhlIHZlcmIgbXVzdCBiZSAnYmFyaywnIG5vdCAnYmFya3MuJyIsICJUaGUgc2VudGVuY2UgYWJvdXQgdGhlIGRvZ3MgaGFzIGFuIGFncmVlbWVudCBlcnJvci4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-04', 'language', 4, convert_from(decode('U3BlbGxpbmcg4oCUIGllIG9yIGVp', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHNwZWxsaW5nLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJJIHdpbGwgcmVjaWV2ZSB0aGUgcGFja2FnZSB0b21vcnJvdy4iLCAiTXkgbmVpZ2hib3IgaGFzIGEgdmVnZXRhYmxlIGdhcmRlbi4iLCAiSSBiZWxpZXZlIHlvdS4iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 1,
 convert_from(decode('VGhlIHJoeW1lICdpIGJlZm9yZSBlLCBleGNlcHQgYWZ0ZXIgYycgY292ZXJzIHJlY2VpdmU6IHJpZ2h0IGFmdGVyIHRoZSBjLCBpdCBpcyBlLWkuIFdvcmRzIGxpa2UgbmVpZ2hib3IgYW5kIHdlaWdoIGZvbGxvdyBhIGRpZmZlcmVudCBwYXR0ZXJuIOKAlCB3aGVuIHRoZSBzb3VuZCBpcyAnYXksJyBpdCBpcyBlLWkuIFNsb3cgZG93biBvbiBhbnkgd29yZCB3aXRoIGllIG9yIGVpIGFuZCBzYXkgaXQgdG8geW91cnNlbGYu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBUaGUgd29yZCBpcyBzcGVsbGVkICdyZWNlaXZlJyDigJQgYWZ0ZXIgYywgaXQgaXMgZSBiZWZvcmUgaS4iLCAiJ05laWdoYm9yJyBpcyBzcGVsbGVkIGNvcnJlY3RseS4gSXQgaXMgb25lIG9mIHRoZSB3b3JkcyB3aGVyZSBlIGNvbWVzIGJlZm9yZSBpIGJlY2F1c2UgaXQgc291bmRzIGxpa2UgJ2F5LiciLCAiJ0JlbGlldmUnIGlzIGNvcnJlY3Q6IGkgYmVmb3JlIGUuIiwgIlRoZSBwYWNrYWdlIHNlbnRlbmNlIGhhcyBhIG1pc3NwZWxsaW5nLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-05', 'language', 5, convert_from(decode('V2hlbiB0aGVyZSBpcyBubyBtaXN0YWtl', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIGNhcGl0YWxpemF0aW9uLCBwdW5jdHVhdGlvbiwgb3IgdXNhZ2UuIENob29zZSB0aGUgc2VudGVuY2UgdGhhdCBoYXMgYW4gZXJyb3IsIG9yIGNob29zZSBObyBtaXN0YWtlcy4=', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJNeSBzaXN0ZXIgcGxheXMgdGhlIHZpb2xpbi4iLCAiSXMgdGhlIGxpYnJhcnkgb3BlbiBvbiBTdW5kYXk/IiwgIldlIGF0ZSBsdW5jaCBhdCBub29uLiIsICJObyBtaXN0YWtlcyJd', 'base64'), 'UTF8')::JSONB, 3, 1,
 convert_from(decode('J05vIG1pc3Rha2VzJyBpcyBhIHJlYWwgYW5zd2VyLCBhbmQgaXQgd2lsbCBiZSByaWdodCBvbiBzb21lIHF1ZXN0aW9ucy4gRG8gbm90IGZvcmNlIGFuIGVycm9yIHRoYXQgaXMgbm90IHRoZXJlLiBDaGVjayBlYWNoIHNlbnRlbmNlIGFnYWluc3QgdGhlIHJ1bGVzIHlvdSBrbm93IOKAlCBjYXBpdGFscywgZW5kIG1hcmtzLCBhZ3JlZW1lbnQg4oCUIGFuZCBpZiBhbGwgdGhyZWUgcGFzcywgdHJ1c3QgeW91ciB3b3JrLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJDYXBpdGFsIGZpcnN0IGxldHRlciwgYSB2ZXJiIHRoYXQgYWdyZWVzLCBhbmQgYSBwZXJpb2QgYXQgdGhlIGVuZCDigJQgbm8gZXJyb3IuIiwgIkEgcXVlc3Rpb24gdGhhdCBjb3JyZWN0bHkgZW5kcyB3aXRoIGEgcXVlc3Rpb24gbWFyaywgd2l0aCBTdW5kYXkgY2FwaXRhbGl6ZWQgYXMgYSBkYXkgb2YgdGhlIHdlZWsuIiwgIk5vdGhpbmcgaXMgd3JvbmcgaGVyZS4gJ05vb24nIGlzIG5vdCBjYXBpdGFsaXplZCBiZWNhdXNlIGl0IGlzIG5vdCBhIG5hbWUuIiwgIkNvcnJlY3QuIEFsbCB0aHJlZSBzZW50ZW5jZXMgYXJlIHdyaXR0ZW4gcHJvcGVybHkuIFNvbWV0aW1lcyB0aGVyZSByZWFsbHkgaXMgbm8gbWlzdGFrZS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-06', 'language', 6, convert_from(decode('QXBvc3Ryb3BoZXMg4oCUIGl0cyBvciBpdCdz', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHB1bmN0dWF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJJdCdzIGdvaW5nIHRvIHJhaW4gdG9kYXkuIiwgIlRoZSBjYXQgbGlja2VkIGl0J3MgcGF3LiIsICJUaGUgY29tcGFueSBjaGFuZ2VkIGl0cyBuYW1lLiIsICJObyBtaXN0YWtlcyJd', 'base64'), 'UTF8')::JSONB, 1, 2,
 convert_from(decode('VGVzdCBldmVyeSAnaXQncycgYnkgZXhwYW5kaW5nIGl0IHRvICdpdCBpcy4nIElmIHRoZSBzZW50ZW5jZSBzdGlsbCBtYWtlcyBzZW5zZSwgdGhlIGFwb3N0cm9waGUgaXMgcmlnaHQuIElmIGl0IGRvZXMgbm90LCB5b3UgbmVlZCAnaXRzLicgVGhpcyBpcyBvbmUgb2YgdGhlIGZldyB3b3JkcyB3aGVyZSB0aGUgcG9zc2Vzc2l2ZSBoYXMgTk8gYXBvc3Ryb3BoZSDigJQganVzdCBsaWtlIGhpcyBhbmQgaGVycy4=', 'base64'), 'UTF8'),
 convert_from(decode('WyInSXQncycgbWVhbnMgJ2l0IGlzLCcgYW5kICdJdCBpcyBnb2luZyB0byByYWluIHRvZGF5JyBtYWtlcyBzZW5zZS4gQ29ycmVjdC4iLCAiQ29ycmVjdC4gJ0l0J3MnIG1lYW5zICdpdCBpcywnIGFuZCAndGhlIGNhdCBsaWNrZWQgaXQgaXMgcGF3JyBtYWtlcyBubyBzZW5zZS4gVGhlIHBvc3Nlc3NpdmUgaXMgJ2l0cywnIHdpdGggbm8gYXBvc3Ryb3BoZS4iLCAiJ0l0cyBuYW1lJyBzaG93cyBvd25lcnNoaXAsIGFuZCB0aGUgcG9zc2Vzc2l2ZSAnaXRzJyBoYXMgbm8gYXBvc3Ryb3BoZS4gQ29ycmVjdC4iLCAiVGhlIHNlbnRlbmNlIGFib3V0IHRoZSBjYXQgbWlzdXNlcyAnaXQncy4nIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-07', 'language', 7, convert_from(decode('UHJvbm91bnMg4oCUIEkgb3IgbWU=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHVzYWdlLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUaGUgY29hY2ggZ2F2ZSB0aGUgYXdhcmQgdG8gU2FyYSBhbmQgbWUuIiwgIlNhcmEgYW5kIEkgZmluaXNoZWQgdGhlIHByb2plY3QuIiwgIk1lIGFuZCBTYXJhIHdlbnQgdG8gdGhlIHN0b3JlLiIsICJObyBtaXN0YWtlcyJd', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('Q292ZXIgdXAgdGhlIG90aGVyIHBlcnNvbiBhbmQgcmVhZCB0aGUgc2VudGVuY2Ugd2l0aCBqdXN0IHRoZSBwcm9ub3VuLiAnTWUgd2VudCcgaXMgd3JvbmcsIHNvIHRoZSBzdG9yZSBzZW50ZW5jZSBuZWVkcyAnSS4nICdHYXZlIHRoZSBhd2FyZCB0byBtZScgaXMgcmlnaHQsIHNvIHRoZSBhd2FyZCBzZW50ZW5jZSBrZWVwcyAnbWUuJyBNYW55IHN0dWRlbnRzIHRoaW5rICdTYXJhIGFuZCBJJyBpcyBhbHdheXMgdGhlIG1vcmUgY29ycmVjdCBjaG9pY2UuIEl0IGlzIG5vdCDigJQgaXQgZGVwZW5kcyBvbiB3aGVyZSB0aGUgd29yZHMgc2l0IGluIHRoZSBzZW50ZW5jZS4=', 'base64'), 'UTF8'),
 convert_from(decode('WyInR2F2ZSB0aGUgYXdhcmQgdG8gbWUnIHNvdW5kcyByaWdodCwgc28gJ3RvIFNhcmEgYW5kIG1lJyBpcyBjb3JyZWN0LiIsICInSSBmaW5pc2hlZCB0aGUgcHJvamVjdCcgd29ya3MsIHNvICdTYXJhIGFuZCBJJyBpcyBjb3JyZWN0LiIsICJDb3JyZWN0LiBUYWtlIGF3YXkgJ2FuZCBTYXJhJzogJ01lIHdlbnQgdG8gdGhlIHN0b3JlJyBpcyB3cm9uZy4gVGhlIHN1YmplY3QgZm9ybSBpcyAnSSc6IFNhcmEgYW5kIEkgd2VudCB0byB0aGUgc3RvcmUuIiwgIlRoZSBzdG9yZSBzZW50ZW5jZSB1c2VzICdtZScgd2hlcmUgJ0knIGlzIG5lZWRlZC4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-08', 'language', 8, convert_from(decode('Q29tbWFzIOKAlCBqb2luaW5nIHR3byBzZW50ZW5jZXM=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHB1bmN0dWF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJBZnRlciBkaW5uZXIsIHdlIHBsYXllZCBhIGdhbWUuIiwgIkkgd2FudGVkIHRvIGdvIHRvIHRoZSBiZWFjaCwgYnV0IGl0IHdhcyByYWluaW5nLiIsICJJIGZpbmlzaGVkIG15IGhvbWV3b3JrLCBJIHdlbnQgb3V0c2lkZS4iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 2, 2,
 convert_from(decode('QSBjb21tYSBhbG9uZSBjYW5ub3Qgam9pbiB0d28gY29tcGxldGUgc2VudGVuY2VzLiBUZXN0IGl0OiBjYW4gZWFjaCBzaWRlIHN0YW5kIG9uIGl0cyBvd24/ICdJIGZpbmlzaGVkIG15IGhvbWV3b3JrJyBhbmQgJ0kgd2VudCBvdXRzaWRlJyBib3RoIGNhbiwgc28gdGhleSBuZWVkIGEgcGVyaW9kLCBhIHNlbWljb2xvbiwgb3IgYSBjb21tYSBQTFVTIGEgam9pbmluZyB3b3JkIGxpa2UgYW5kLCBidXQsIG9yIHNvLiBUaGUgYmVhY2ggc2VudGVuY2UgaGFzICdidXQnOyB0aGUgaG9tZXdvcmsgc2VudGVuY2UgZG9lcyBub3Qu', 'base64'), 'UTF8'),
 convert_from(decode('WyJBIGNvbW1hIGFmdGVyIGFuIGludHJvZHVjdG9yeSBwaHJhc2UgbGlrZSAnQWZ0ZXIgZGlubmVyJyBpcyBjb3JyZWN0LiIsICJUd28gY29tcGxldGUgc2VudGVuY2VzIGpvaW5lZCBieSBhIGNvbW1hIHBsdXMgJ2J1dCcg4oCUIGNvcnJlY3QuIiwgIkNvcnJlY3QuIFR3byBjb21wbGV0ZSBzZW50ZW5jZXMgYXJlIGpvaW5lZCBieSBvbmx5IGEgY29tbWEsIHdoaWNoIGlzIGNhbGxlZCBhIGNvbW1hIHNwbGljZS4gQWRkIGEgam9pbmluZyB3b3JkICgnYW5kIHRoZW4nKSBvciB1c2UgYSBwZXJpb2QuIiwgIlRoZSBob21ld29yayBzZW50ZW5jZSBpcyBhIGNvbW1hIHNwbGljZS4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-09', 'language', 9, convert_from(decode('Q2FwaXRhbGl6YXRpb24g4oCUIG5hbWVzIGFuZCB0aXRsZXM=', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIGNhcGl0YWxpemF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJXZSByZWFkIGFib3V0IHRoZSBEZWNsYXJhdGlvbiBvZiBpbmRlcGVuZGVuY2UuIiwgIk15IHVuY2xlIGlzIGEgZG9jdG9yLiIsICJHcmFuZG1hIG1hZGUgcGFuY2FrZXMgdGhpcyBtb3JuaW5nLiIsICJObyBtaXN0YWtlcyJd', 'base64'), 'UTF8')::JSONB, 0, 2,
 convert_from(decode('VGhlIG5hbWVzIG9mIHNwZWNpZmljIHRoaW5ncyDigJQgZG9jdW1lbnRzLCBob2xpZGF5cywgZXZlbnRzIOKAlCBjYXBpdGFsaXplIGV2ZXJ5IGltcG9ydGFudCB3b3JkLCB3aGlsZSBzbWFsbCB3b3JkcyBsaWtlICdvZicgc3RheSBsb3dlcmNhc2UuIEpvYiB0aXRsZXMgYW5kIGZhbWlseSB3b3JkcyBzdGF5IGxvd2VyY2FzZSB1bmxlc3MgdGhleSBhcmUgdXNlZCBBUyBhIG5hbWU6ICdteSBncmFuZG1hIG1hZGUgcGFuY2FrZXMsJyBidXQgJ0dyYW5kbWEgbWFkZSBwYW5jYWtlcy4n', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBFdmVyeSBpbXBvcnRhbnQgd29yZCBpbiB0aGUgbmFtZSBvZiBhIGRvY3VtZW50IGlzIGNhcGl0YWxpemVkOiBEZWNsYXJhdGlvbiBvZiBJbmRlcGVuZGVuY2UuIiwgIidEb2N0b3InIGlzIGEgam9iLCBub3QgYSBuYW1lLCBzbyBpdCBzdGF5cyBsb3dlcmNhc2UuIENvcnJlY3QgYXMgd3JpdHRlbi4iLCAiJ0dyYW5kbWEnIGlzIHVzZWQgYXMgaGVyIG5hbWUgaGVyZSwgc28gaXQgaXMgY2FwaXRhbGl6ZWQuIENvcnJlY3QuIiwgIlRoZSBEZWNsYXJhdGlvbiBzZW50ZW5jZSBoYXMgYSBjYXBpdGFsaXphdGlvbiBlcnJvci4iXQ==', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-10', 'language', 10, convert_from(decode('Q29tcG9zaXRpb24g4oCUIHRyYW5zaXRpb24gd29yZHM=', 'base64'), 'UTF8'),
 convert_from(decode('Q2hvb3NlIHRoZSB3b3JkIG9yIHBocmFzZSB0aGF0IGJlc3QgY29tcGxldGVzIHRoZSBzZWNvbmQgc2VudGVuY2UuCk1heWEgc3R1ZGllZCBldmVyeSBuaWdodCBmb3IgdHdvIHdlZWtzLgpfX19fX18sIHNoZSBlYXJuZWQgdGhlIGhpZ2hlc3Qgc2NvcmUgaW4gaGVyIGNsYXNzLg==', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJIb3dldmVyIiwgIkZvciBleGFtcGxlIiwgIk1lYW53aGlsZSIsICJBcyBhIHJlc3VsdCJd', 'base64'), 'UTF8')::JSONB, 3, 2,
 convert_from(decode('VHJhbnNpdGlvbiB3b3JkcyBzaG93IGhvdyB0d28gaWRlYXMgY29ubmVjdC4gQXNrIHdoYXQgdGhlIHNlY29uZCBzZW50ZW5jZSBpcyB0byB0aGUgZmlyc3Q6IGEgY29udHJhc3QsIGFuIGV4YW1wbGUsIGEgcmVzdWx0LCBvciBzb21ldGhpbmcgaGFwcGVuaW5nIGF0IHRoZSBzYW1lIHRpbWU/IFN0dWR5aW5nIGxlZCB0byB0aGUgaGlnaCBzY29yZSwgc28gdGhlIGxpbmsgaXMgY2F1c2UgYW5kIGVmZmVjdDogQXMgYSByZXN1bHQu', 'base64'), 'UTF8'),
 convert_from(decode('WyInSG93ZXZlcicgc2lnbmFscyBhIGNvbnRyYXN0LCBidXQgdGhlIGhpZ2ggc2NvcmUgaXMgdGhlIGV4cGVjdGVkIHBheW9mZiBvZiBzdHVkeWluZywgbm90IGEgc3VycHJpc2UuIiwgIidGb3IgZXhhbXBsZScgaW50cm9kdWNlcyBhbiBpbGx1c3RyYXRpb24gb2YgYSBnZW5lcmFsIHBvaW50LiBUaGUgc2Vjb25kIHNlbnRlbmNlIGlzIGFuIG91dGNvbWUsIG5vdCBhbiBleGFtcGxlLiIsICInTWVhbndoaWxlJyBtZWFucyBhdCB0aGUgc2FtZSB0aW1lLCBidXQgdGhlIHNjb3JlIGNhbWUgQUZURVIgdGhlIHN0dWR5aW5nLiIsICJDb3JyZWN0LiBUaGUgaGlnaCBzY29yZSBoYXBwZW5lZCBiZWNhdXNlIHNoZSBzdHVkaWVkIOKAlCBhIGNhdXNlIGFuZCBpdHMgZWZmZWN0LiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-11', 'language', 11, convert_from(decode('VmVyYiB0ZW5zZQ==', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHVzYWdlLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUb21vcnJvdyBzaGUgd2lsbCB2aXNpdCBoZXIgYXVudC4iLCAiWWVzdGVyZGF5IHdlIHdhbGsgdG8gdGhlIHBhcmsgYW5kIHNhdyBhIHBhcmFkZS4iLCAiRXZlcnkgbW9ybmluZyBoZSBydW5zIHR3byBtaWxlcy4iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('TG9vayBmb3IgdGltZSBjbHVlcyDigJQgeWVzdGVyZGF5LCB0b21vcnJvdywgZXZlcnkgZGF5IOKAlCBhbmQgbWFrZSBldmVyeSB2ZXJiIGFncmVlIHdpdGggdGhlbS4gSW4gdGhlIHBhcmFkZSBzZW50ZW5jZSwgJ3llc3RlcmRheScgYW5kICdzYXcnIGFyZSBib3RoIHBhc3QsIGJ1dCAnd2FsaycgaXMgcHJlc2VudC4gVGVuc2UgZXJyb3JzIGhpZGUgaW4gc2VudGVuY2VzIHdpdGggdHdvIHZlcmJzLCB3aGVyZSBvbmUgaXMgcmlnaHQgYW5kIHRoZSBvdGhlciBxdWlldGx5IGlzIG5vdC4=', 'base64'), 'UTF8'),
 convert_from(decode('WyInVG9tb3Jyb3cnIHdpdGggJ3dpbGwgdmlzaXQnIOKAlCB0aGUgZnV0dXJlIHRlbnNlIG1hdGNoZXMuIiwgIkNvcnJlY3QuICdZZXN0ZXJkYXknIHB1dHMgdGhlIHNlbnRlbmNlIGluIHRoZSBwYXN0LCBhbmQgJ3NhdycgaXMgcGFzdCB0ZW5zZSwgc28gJ3dhbGsnIG11c3QgYmUgJ3dhbGtlZC4nIiwgIidFdmVyeSBtb3JuaW5nJyBkZXNjcmliZXMgYSBoYWJpdCwgYW5kICdydW5zJyBpcyB0aGUgcHJlc2VudCB0ZW5zZSB1c2VkIGZvciBoYWJpdHMuIENvcnJlY3QuIiwgIlRoZSBwYXJhZGUgc2VudGVuY2Ugc3dpdGNoZXMgdGVuc2UgcGFydHdheSB0aHJvdWdoLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-12', 'language', 12, convert_from(decode('UHJvbm91bnMg4oCUIHdobyBvciB3aG9t', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHVzYWdlLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUbyB3aG8gZGlkIHlvdSBnaXZlIHRoZSBib29rPyIsICJXaG9tIHNob3VsZCBJIGludml0ZSB0byB0aGUgcGFydHk/IiwgIldobyBpcyBrbm9ja2luZyBhdCB0aGUgZG9vcj8iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 0, 3,
 convert_from(decode('QW5zd2VyIHRoZSBxdWVzdGlvbiB3aXRoIGhlIG9yIGhpbS4gSWYgdGhlIGFuc3dlciB1c2VzIEhFLCBjaG9vc2Ugd2hvOyBpZiBpdCB1c2VzIEhJTSwgY2hvb3NlIHdob20g4oCUIGhpbSBhbmQgd2hvbSBib3RoIGVuZCBpbiBtLiAnWW91IGdhdmUgdGhlIGJvb2sgdG8gSElNLCcgc28gaXQgaXMgJ3RvIHdob20uJyBXb3JkcyBsaWtlIHRvLCBmb3IsIGFuZCB3aXRoIGFyZSBhIHN0cm9uZyBjbHVlIHRoYXQgd2hvbSBpcyBjb21pbmcu', 'base64'), 'UTF8'),
 convert_from(decode('WyJDb3JyZWN0LiBBZnRlciBhIHdvcmQgbGlrZSAndG8sJyB1c2UgJ3dob20nOiBUbyB3aG9tIGRpZCB5b3UgZ2l2ZSB0aGUgYm9vaz8iLCAiQW5zd2VyIGl0OiAnSSBzaG91bGQgaW52aXRlIEhJTS4nIEhpbSBlbmRzIGluIG0sIHNvICd3aG9tJyBpcyBjb3JyZWN0LiIsICJBbnN3ZXIgaXQ6ICdIRSBpcyBrbm9ja2luZy4nIEhlIGRvZXMgbm90IGVuZCBpbiBtLCBzbyAnd2hvJyBpcyBjb3JyZWN0LiIsICJUaGUgYm9vayBzZW50ZW5jZSB1c2VzICd3aG8nIHdoZXJlICd3aG9tJyBpcyBuZWVkZWQuIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-13', 'language', 13, convert_from(decode('U2VtaWNvbG9ucw==', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHB1bmN0dWF0aW9uLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJJIGxvdmUgdG8gcmVhZDsgbXkgYnJvdGhlciBwcmVmZXJzIHNwb3J0cy4iLCAiVGhlIHN0b3JtIHdhcyBmaWVyY2U7IGhvd2V2ZXIsIG5vIG9uZSB3YXMgaHVydC4iLCAiQmVjYXVzZSBpdCB3YXMgbGF0ZTsgd2Ugd2VudCBob21lLiIsICJObyBtaXN0YWtlcyJd', 'base64'), 'UTF8')::JSONB, 2, 3,
 convert_from(decode('QSBzZW1pY29sb24gd29ya3MgbGlrZSBhIHNvZnQgcGVyaW9kOiBib3RoIHNpZGVzIG11c3QgYmUgY29tcGxldGUgc2VudGVuY2VzLiBUZXN0IGVhY2ggc2lkZSBvbiBpdHMgb3duLiAnTXkgYnJvdGhlciBwcmVmZXJzIHNwb3J0cycgc3RhbmRzIGFsb25lOyAnQmVjYXVzZSBpdCB3YXMgbGF0ZScgZG9lcyBub3Qg4oCUIGl0IGxlYXZlcyB5b3Ugd2FpdGluZyBmb3IgdGhlIHJlc3QuIENsYXVzZXMgdGhhdCBzdGFydCB3aXRoIGJlY2F1c2UsIHdoZW4sIG9yIGFsdGhvdWdoIG5lZWQgYSBjb21tYSwgbm90IGEgc2VtaWNvbG9uLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJCb3RoIHNpZGVzIGFyZSBjb21wbGV0ZSBzZW50ZW5jZXMsIHNvIHRoZSBzZW1pY29sb24gam9pbnMgdGhlbSBjb3JyZWN0bHkuIiwgIkEgc2VtaWNvbG9uIGJlZm9yZSAnaG93ZXZlcicgam9pbnMgdHdvIGNvbXBsZXRlIHNlbnRlbmNlcywgd2l0aCBhIGNvbW1hIGFmdGVyIGl0LiBDb3JyZWN0LiIsICJDb3JyZWN0LiAnQmVjYXVzZSBpdCB3YXMgbGF0ZScgY2Fubm90IHN0YW5kIGFsb25lIGFzIGEgc2VudGVuY2UsIHNvIGl0IGNhbm5vdCBzaXQgYmVmb3JlIGEgc2VtaWNvbG9uLiBVc2UgYSBjb21tYTogQmVjYXVzZSBpdCB3YXMgbGF0ZSwgd2Ugd2VudCBob21lLiIsICJUaGUgc2VudGVuY2UgYWJvdXQgaXQgYmVpbmcgbGF0ZSBtaXN1c2VzIGEgc2VtaWNvbG9uLiJd', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-14', 'language', 14, convert_from(decode('Q29tcG9zaXRpb24g4oCUIHRvcGljIHNlbnRlbmNlcw==', 'base64'), 'UTF8'),
 convert_from(decode('V2hpY2ggc2VudGVuY2Ugd291bGQgYmVzdCBiZWdpbiBhIHBhcmFncmFwaCBhYm91dCB0aGUgYmVuZWZpdHMgb2YgbGVhcm5pbmcgYSBzZWNvbmQgbGFuZ3VhZ2U/', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJNYW55IHBlb3BsZSBhcm91bmQgdGhlIHdvcmxkIHNwZWFrIG1vcmUgdGhhbiBvbmUgbGFuZ3VhZ2UuIiwgIlNwYW5pc2ggaXMgc3Bva2VuIGluIG1hbnkgZGlmZmVyZW50IGNvdW50cmllcy4iLCAiTXkgZnJpZW5kIGlzIGxlYXJuaW5nIEZyZW5jaCB0aGlzIHllYXIuIiwgIkxlYXJuaW5nIGEgc2Vjb25kIGxhbmd1YWdlIGNhbiBvcGVuIGRvb3JzIGluIHNjaG9vbCwgdHJhdmVsLCBhbmQgd29yay4iXQ==', 'base64'), 'UTF8')::JSONB, 3, 3,
 convert_from(decode('QSB0b3BpYyBzZW50ZW5jZSB0ZWxscyB0aGUgcmVhZGVyIHdoYXQgdGhlIHdob2xlIHBhcmFncmFwaCB3aWxsIGJlIGFib3V0LiBJdCBzaG91bGQgYmUgYnJvYWQgZW5vdWdoIHRvIGNvdmVyIGV2ZXJ5IHNlbnRlbmNlIHRoYXQgZm9sbG93cywgeWV0IHNwZWNpZmljIGVub3VnaCB0byBtYWtlIGEgcG9pbnQuIEZhY3RzIGFuZCBwZXJzb25hbCBleGFtcGxlcyBhcmUgc3VwcG9ydGluZyBkZXRhaWxzIOKAlCB0aGV5IGJlbG9uZyBsYXRlciBpbiB0aGUgcGFyYWdyYXBoLg==', 'base64'), 'UTF8'),
 convert_from(decode('WyJUcnVlLCBidXQgaXQgc3RhdGVzIGEgZmFjdCB3aXRob3V0IHNheWluZyB3aHkgbGVhcm5pbmcgYSBsYW5ndWFnZSBoZWxwcy4gSXQgZG9lcyBub3QgcG9pbnQgdG93YXJkIGJlbmVmaXRzLiIsICJUaGlzIGlzIGEgZGV0YWlsIGFib3V0IG9uZSBsYW5ndWFnZSDigJQgdG9vIG5hcnJvdyB0byBpbnRyb2R1Y2UgdGhlIHdob2xlIHRvcGljLiIsICJBIHBlcnNvbmFsIGV4YW1wbGUgd29ya3MgaW4gdGhlIG1pZGRsZSBvZiBhIHBhcmFncmFwaCwgbm90IGFzIHRoZSBzZW50ZW5jZSB0aGF0IHNldHMgdXAgdGhlIG1haW4gaWRlYS4iLCAiQ29ycmVjdC4gSXQgbmFtZXMgdGhlIHRvcGljIGFuZCBwcmV2aWV3cyB0aGUgYmVuZWZpdHMgdGhlIHBhcmFncmFwaCB3aWxsIGV4cGxhaW4uIl0=', 'base64'), 'UTF8')::JSONB),

('train-hspt-language-15', 'language', 15, convert_from(decode('U3BlbGxpbmcg4oCUIGRvdWJsZSBsZXR0ZXJz', 'base64'), 'UTF8'),
 convert_from(decode('TG9vayBmb3IgZXJyb3JzIGluIHNwZWxsaW5nLiBDaG9vc2UgdGhlIHNlbnRlbmNlIHRoYXQgaGFzIGFuIGVycm9yLCBvciBjaG9vc2UgTm8gbWlzdGFrZXMu', 'base64'), 'UTF8'),
 NULL::TEXT,
 convert_from(decode('WyJUaGUgaG90ZWwgY2FuIGFjY29tbW9kYXRlIGEgbGFyZ2UgZ3JvdXAuIiwgIkl0IGlzIG5lY2Nlc3NhcnkgdG8gYnJpbmcgYSBwZW5jaWwuIiwgIldlIGNlbGVicmF0ZSBvbiBzcGVjaWFsIG9jY2FzaW9ucy4iLCAiTm8gbWlzdGFrZXMiXQ==', 'base64'), 'UTF8')::JSONB, 1, 3,
 convert_from(decode('V29yZHMgd2l0aCBkb3VibGUgbGV0dGVycyBhcmUgYW1vbmcgdGhlIG1vc3QgbWlzc3BlbGxlZCBvbiB0aGUgdGVzdC4gTWVtb3J5IHRyaWNrcyBoZWxwOiBuZWNlc3NhcnkgaGFzIG9uZSBDb2xsYXIgYW5kIHR3byBTbGVldmVzIOKAlCBvbmUgYywgdHdvIHMncy4gQWNjb21tb2RhdGUgaXMgYmlnIGVub3VnaCB0byBob2xkIHR3byBjJ3MgYW5kIHR3byBtJ3MuIFdoZW4gYSB3b3JkIGxvb2tzIGFsbW9zdCByaWdodCwgY2hlY2sgd2hpY2ggbGV0dGVyIGlzIGRvdWJsZWQu', 'base64'), 'UTF8'),
 convert_from(decode('WyInQWNjb21tb2RhdGUnIGlzIGNvcnJlY3Qg4oCUIGl0IGhhcyBhIGRvdWJsZSBjIEFORCBhIGRvdWJsZSBtLiIsICJDb3JyZWN0LiAnTmVjZXNzYXJ5JyBoYXMgb25lIGMgYW5kIHR3byBzJ3MuIFRoZSBtaXNzcGVsbGluZyBkb3VibGVzIHRoZSB3cm9uZyBsZXR0ZXIuIiwgIidPY2Nhc2lvbnMnIGlzIGNvcnJlY3Q6IGRvdWJsZSBjLCBzaW5nbGUgcy4iLCAiVGhlIHBlbmNpbCBzZW50ZW5jZSBoYXMgYSBtaXNzcGVsbGluZy4iXQ==', 'base64'), 'UTF8')::JSONB)
) AS v(key, section, sort_order, concept, prompt, passage, options, correct_index, difficulty, explanation, option_notes);


-- ── Verification ─────────────────────────────────────────────────────────────
--
-- One row per section. Expected on every row:
--   questions 15 · easy 5 · medium 5 · hard 5 · labelled 15 · notes_ok true
--   max_answer_share <= 27%
-- and scoring_bank_untouched = 1500 on every row (the quiz bank never moves).

SELECT
  t.section::TEXT                                                   AS section,
  COUNT(*)                                                          AS questions,
  COUNT(*) FILTER (WHERE t.difficulty = 1)                          AS easy,
  COUNT(*) FILTER (WHERE t.difficulty = 2)                          AS medium,
  COUNT(*) FILTER (WHERE t.difficulty = 3)                          AS hard,
  COUNT(t.concept)                                                  AS labelled,
  bool_and(jsonb_array_length(t.option_notes) = 4
           AND NOT (t.option_notes::TEXT LIKE '%""%'))              AS notes_ok,
  ROUND(100.0 * MAX(pos.n) / COUNT(*)) || '%'                          AS max_answer_share,
  (SELECT COUNT(*) FROM questions)                                  AS scoring_bank_untouched,
  -- Hash of every prompt, option, note and explanation as STORED, compared to
  -- the hash of the validated source. Catches anything corrupted between the
  -- generator and the database — a slipped character in a copy and paste
  -- passes every count above but fails here.
  (SELECT md5(string_agg(concat_ws('|', c.concept, c.prompt, COALESCE(c.passage, ''),
                                     c.options::TEXT, c.option_notes::TEXT, c.explanation,
                                     c.correct_index::TEXT, c.difficulty::TEXT),
                           '#' ORDER BY c.section::TEXT, c.sort_order))
     FROM training_questions AS c
    WHERE c.exam = 'hspt') = 'd3b78e485f58e4f16abc39ed109aa40e'                            AS content_intact
FROM training_questions t
JOIN LATERAL (
  SELECT COUNT(*) AS n FROM training_questions t2
  WHERE t2.section = t.section AND t2.correct_index = t.correct_index
) pos ON true
WHERE t.exam = 'hspt'
GROUP BY t.section
ORDER BY t.section;
