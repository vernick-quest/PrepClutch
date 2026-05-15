export type Section = 'verbal' | 'quantitative' | 'reading' | 'math' | 'language'

export interface Profile {
  id: string
  display_name: string
  class_code: string
  avatar_color: string
  created_at: string
}

export interface Question {
  id: string
  section: Section
  prompt: string
  passage: string | null
  options: string[]
  correct_index: number
  difficulty: number
  explanation?: string
}

export interface QuizAttempt {
  id: string
  user_id: string
  started_at: string
  completed_at: string | null
  section: Section | 'full'
  score: number
  total_questions: number
}

export interface AchievementDefinition {
  id: string
  key: string
  label: string
  description: string
  icon_emoji: string
  threshold: number
}

export interface UserAchievement {
  user_id: string
  achievement_key: string
  earned_at: string
}

export interface LeaderboardEntry {
  user_id: string
  display_name: string
  avatar_color: string
  aggregate_score: number
  section_scores: Record<Section, number>
  achievements: string[]
}

export interface QuizAnswer {
  question_id: string
  selected_index: number
  correct_index: number
  time_taken_ms: number
  xp_earned: number
}

export interface QuizResult {
  attempt_id: string
  section: Section | 'full'
  answers: QuizAnswer[]
  total_xp: number
  score: number
  total_questions: number
  new_achievements: AchievementDefinition[]
}
