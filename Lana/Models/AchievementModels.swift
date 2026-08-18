import SwiftUI

// MARK: - Achievement Definition

struct AchievementDef: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let group: String
}

// MARK: - All Achievements

extension AchievementDef {

    private static let yellow  = Color(red: 0.98, green: 0.79, blue: 0.20)
    private static let green   = Color(red: 0.20, green: 0.78, blue: 0.43)
    private static let blue    = Color(red: 0.22, green: 0.44, blue: 0.98)
    private static let purple  = Color(red: 0.62, green: 0.38, blue: 0.98)
    private static let peach   = Color(red: 0.98, green: 0.55, blue: 0.20)

    static let all: [AchievementDef] = [

        // MARK: Streaks
        AchievementDef(id: "streak_3",   title: "On Fire",          description: "Keep a 3-day streak",              icon: "flame.fill",                         color: .orange,  group: "Streaks"),
        AchievementDef(id: "streak_7",   title: "Week Warrior",     description: "Reach a 7-day streak",             icon: "bolt.fill",                          color: .orange,  group: "Streaks"),
        AchievementDef(id: "streak_30",  title: "Unstoppable",      description: "Reach a 30-day streak",            icon: "bolt.circle.fill",                   color: .red,     group: "Streaks"),

        // MARK: XP
        AchievementDef(id: "xp_100",     title: "Rising Star",      description: "Earn 100 XP",                      icon: "sparkles",                           color: yellow,   group: "XP"),
        AchievementDef(id: "xp_500",     title: "Pro Learner",      description: "Earn 500 XP",                      icon: "star.fill",                          color: yellow,   group: "XP"),
        AchievementDef(id: "xp_1000",    title: "Champion",         description: "Earn 1 000 XP",                    icon: "medal.fill",                         color: .yellow,  group: "XP"),
        AchievementDef(id: "xp_5000",    title: "Legend",           description: "Earn 5 000 XP",                    icon: "crown.fill",                         color: .yellow,  group: "XP"),

        // MARK: Words
        AchievementDef(id: "word_saver",     title: "Word Saver",    description: "Save 5 words",                    icon: "bookmark.fill",                      color: purple,   group: "Words"),
        AchievementDef(id: "word_collector", title: "Collector",     description: "Save 20 words",                   icon: "bookmark.circle.fill",               color: purple,   group: "Words"),
        AchievementDef(id: "words_50",       title: "Vocab Pro",     description: "Save 50 words",                   icon: "books.vertical.fill",                color: purple,   group: "Words"),
        AchievementDef(id: "words_100",      title: "Lexicon Master",description: "Save 100 words",                  icon: "text.book.closed.fill",              color: purple,   group: "Words"),

        // MARK: Lessons
        AchievementDef(id: "first_lesson", title: "First Step",     description: "Complete your first lesson",       icon: "graduationcap.fill",                 color: green,    group: "Lessons"),
        AchievementDef(id: "five_lessons", title: "Bookworm",       description: "Complete 5 lessons",               icon: "books.vertical.fill",                color: green,    group: "Lessons"),
        AchievementDef(id: "all_lessons",  title: "Scholar",        description: "Complete all lessons",             icon: "star.fill",                          color: green,    group: "Lessons"),

        // MARK: Quizzes
        AchievementDef(id: "first_quiz",   title: "Quiz Taker",     description: "Complete your first quiz",         icon: "checkmark.circle.fill",              color: green,    group: "Quizzes"),
        AchievementDef(id: "perfect_quiz", title: "Perfectionist",  description: "Score 100% on any quiz",           icon: "medal.fill",                         color: .yellow,  group: "Quizzes"),
        AchievementDef(id: "quiz_master",  title: "Quiz Master",    description: "Complete 10 quizzes",              icon: "trophy.fill",                        color: green,    group: "Quizzes"),

        // MARK: Practice
        AchievementDef(id: "first_mistake_review",   title: "Learner",        description: "Complete a mistake review",      icon: "arrow.uturn.backward.circle.fill",  color: peach,    group: "Practice"),
        AchievementDef(id: "first_typing",           title: "Typist",         description: "Finish a typing practice round", icon: "keyboard.fill",                     color: blue,     group: "Practice"),
        AchievementDef(id: "first_audio_quiz",       title: "Good Ear",       description: "Finish an audio quiz",           icon: "ear.fill",                          color: blue,     group: "Practice"),
        AchievementDef(id: "first_match_madness",    title: "Memory Match",   description: "Play Match Madness",             icon: "square.grid.2x2.fill",              color: yellow,   group: "Practice"),
        AchievementDef(id: "first_sentence_builder", title: "Sentence Maker", description: "Finish a Sentence Builder round",icon: "text.alignleft",                    color: purple,   group: "Practice"),

        // MARK: Levels
        AchievementDef(id: "level_5",  title: "Level 5 Unlocked", description: "Reach Level 5",                     icon: "rosette",                            color: blue,     group: "Levels"),
        AchievementDef(id: "level_10", title: "Level 10 Pro",     description: "Reach Level 10",                    icon: "trophy.fill",                        color: .orange,  group: "Levels"),
        AchievementDef(id: "level_20", title: "English Expert",   description: "Reach Level 20",                    icon: "crown.fill",                         color: .yellow,  group: "Levels"),
    ]

    static let groups: [String] = ["Streaks", "XP", "Words", "Lessons", "Quizzes", "Practice", "Levels"]
}
