// ── Recording a finished quiz ────────────────────────────────────────────────
//
// One place where a completed session is written, so the solo flows and the
// full practice test cannot drift. The reading bug that started all of this
// (points shown on the results page, then gone from the section total) was a
// second copy of this logic missing the history upsert — see migration 008.

import { awardSectionMasteryBadges } from '@/lib/section-mastery'
import { checkAchievements } from '@/lib/achievements'
import type { Question, QuizAnswer } from '@/types/database'

interface FinishArgs {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: any
  userId: string
  section: string
  answers: QuizAnswer[]
  questions: Question[]
  /** Questions already mastered before this session started. */
  masteredIds: string[]
}

/**
 * Persist an attempt, record per-question history, award badges, and stash the
 * result for /results. Returns the payload written to sessionStorage.
 *
 * ORDER MATTERS: the history upserts must complete before the mastery badges
 * are evaluated, or the milestone crossed by the last question is missed.
 */
export async function finishAndRecordQuiz({
  supabase, userId, section, answers, questions, masteredIds,
}: FinishArgs) {
  const score   = answers.filter(a => a.selected_index === a.correct_index).length
  const totalXP = answers.reduce((s, a) => s + a.xp_earned, 0)
  const total   = answers.length

  const { data: attempt } = await supabase
    .from('quiz_attempts')
    .insert({
      user_id:         userId,
      section,
      score,
      total_questions: total,
      answers,
      total_xp:        totalXP,
      completed_at:    new Date().toISOString(),
    })
    .select()
    .single()

  // get_section_mastery and leaderboard_view both derive a section total from
  // user_question_history JOIN questions. Skipping this leaves the points
  // stranded on the results page and out of the student's actual score.
  for (const a of answers) {
    await supabase.rpc('upsert_question_history', {
      p_user_id:     userId,
      p_question_id: a.question_id,
      p_correct:     a.selected_index === a.correct_index,
    })
  }

  await checkAchievements(supabase, userId, answers, score, total, section, questions)

  // Reuses the get_section_mastery() call the badge step already makes. The
  // results page needs these to tell "you finished this section" apart from
  // "this round earned nothing" — both show +0 and only one is good news.
  const { rows: mastery } = await awardSectionMasteryBadges(supabase, userId)

  // Only newly mastered questions raise a section total, so report the review
  // portion separately rather than implying every point earned was a gain.
  const alreadyMastered = new Set(masteredIds)
  const reviewXP = answers
    .filter(a => alreadyMastered.has(a.question_id))
    .reduce((s, a) => s + a.xp_earned, 0)

  const payload = {
    attempt_id:      attempt?.id,
    section,
    answers,
    total_xp:        totalXP,
    new_xp:          totalXP - reviewXP,
    review_xp:       reviewXP,
    score,
    total_questions: total,
    questions,
    mastery,
  }

  sessionStorage.setItem('quiz_result', JSON.stringify(payload))
  return payload
}
