/** Compare place names loosely: case, accents and apostrophe styles ignored. */
export function normName(s: string): string {
  return s.normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[ʻ’‘`]/g, "'").toLowerCase().trim()
}
