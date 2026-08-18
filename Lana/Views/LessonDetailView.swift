import SwiftUI

// MARK: - Data

struct LessonContent {
    let vocabulary: [(word: String, translation: String, example: String)]
    let phrases: [(english: String, note: String)]
    let tip: String
    let realLife: [(scenario: String, howTo: String)]  // R8-F: Use This In Real Life
}

enum LessonContentProvider {
    static func content(for id: String) -> LessonContent {
        switch id {
        case "health":
            return LessonContent(
                vocabulary: [
                    ("symptom",      "симптом",       "A headache is a common symptom of stress."),
                    ("prescription", "рецепт",        "The doctor gave me a prescription for antibiotics."),
                    ("appointment",  "запись/приём",  "I have a doctor's appointment at 3 p.m."),
                    ("diagnosis",    "диагноз",       "The diagnosis was confirmed after the tests."),
                    ("treatment",    "лечение",       "The treatment lasts for two weeks.")
                ],
                phrases: [
                    ("I haven't been feeling well lately.",    "Use this to start a conversation with a doctor."),
                    ("What are the side effects?",            "Ask about risks of medication."),
                    ("Could you refer me to a specialist?",   "Request to see a specific doctor."),
                    ("I'm allergic to penicillin.",           "Always mention allergies to your doctor.")
                ],
                tip: "In English-speaking countries you usually need to 'make an appointment' — you can't just walk in to see a doctor.",
                realLife: [
                    ("At a UK GP surgery", "Say: 'I'd like to make an appointment with Dr Smith, please. It's not urgent.' Then describe your main symptom clearly."),
                    ("At a pharmacy", "Say: 'Could I get something for a headache/sore throat?' The pharmacist will recommend an over-the-counter medicine.")
                ]
            )

        case "tv":
            return LessonContent(
                vocabulary: [
                    ("episode",    "серия",        "I watched three episodes in a row."),
                    ("character",  "персонаж",     "My favourite character is the detective."),
                    ("plot twist", "неожиданный поворот", "The plot twist at the end was shocking."),
                    ("sequel",     "продолжение",  "The sequel was even better than the original."),
                    ("binge-watch","смотреть запоем", "I binge-watched the whole series in one weekend.")
                ],
                phrases: [
                    ("Have you seen Breaking Bad?",               "Start a TV recommendation conversation."),
                    ("It's a must-watch — you won't regret it.",  "Strongly recommend something."),
                    ("I'm totally hooked on this show.",          "Say you're addicted to a series."),
                    ("I can't believe they cancelled it!",        "Express disappointment about cancellation.")
                ],
                tip: "Native speakers say 'I'm on season 3' (not 'I'm at season 3') when talking about where they are in a series.",
                realLife: [
                    ("Making small talk with colleagues", "Ask: 'Have you been watching anything good lately?' Then use: 'I've been binge-watching [show name] — it's totally addictive!'"),
                    ("Recommending a show to a friend", "Say: 'You have to watch [show]. It's a must-watch. The plot twists are incredible.' Give one compelling reason.")
                ]
            )

        case "food":
            return LessonContent(
                vocabulary: [
                    ("ingredient",  "ингредиент",   "The key ingredient is fresh basil."),
                    ("cuisine",     "кухня",        "I love Italian cuisine."),
                    ("flavour",     "вкус/аромат",  "This dish has a rich, smoky flavour."),
                    ("portion",     "порция",       "The portions here are very generous."),
                    ("savoury",     "несладкий/пикантный", "I prefer savoury food over sweet.")
                ],
                phrases: [
                    ("Could I have the bill, please?",        "Politely ask for the check in a restaurant."),
                    ("What do you recommend?",                "Ask a waiter for their suggestion."),
                    ("I'm a vegetarian / I'm vegan.",         "Explain your dietary preferences."),
                    ("This is absolutely delicious!",         "Compliment the food enthusiastically.")
                ],
                tip: "In the UK people say 'flavour' and 'savoury'. In the US they say 'flavor' and 'savory'. Both are correct!",
                realLife: [
                    ("Ordering in a British restaurant", "When the waiter comes, say: 'Could I have the [dish], please?' At the end: 'Could we have the bill when you're ready?' Avoid snapping fingers — it's very rude."),
                    ("Telling a friend about a restaurant", "Try: 'I went to this amazing Italian place last night. The pasta was absolutely delicious and the portions were huge!'")
                ]
            )

        case "work":
            return LessonContent(
                vocabulary: [
                    ("deadline",   "дедлайн",      "The deadline for the project is Friday."),
                    ("colleague",  "коллега",      "My colleague helped me prepare the report."),
                    ("promotion",  "повышение",    "She received a promotion after six months."),
                    ("remote",     "удалённый",    "I've been working remote for two years."),
                    ("feedback",   "обратная связь", "Could you give me feedback on my presentation?")
                ],
                phrases: [
                    ("Could you clarify what you mean?",          "Ask for explanation politely in a meeting."),
                    ("I'm responsible for the marketing team.",    "Describe your role at work."),
                    ("Let's schedule a call for Thursday.",        "Arrange a meeting professionally."),
                    ("I'd like to follow up on my application.",   "Chase up a job application by email.")
                ],
                tip: "In professional emails always start with 'I hope this email finds you well' and end with 'Kind regards' or 'Best wishes'.",
                realLife: [
                    ("Writing a professional email", "Start: 'Dear [Name], I hope this email finds you well.' Then state your request clearly. End: 'Kind regards, [Your name].' Never write 'Dear Sir or Madam' unless you truly don't know the name."),
                    ("Speaking in a video meeting", "When you want to say something, use: 'Can I jump in here?' or 'Just to add to that...' When confused: 'Could you clarify what you mean by [word]?'")
                ]
            )

        case "travel":
            return LessonContent(
                vocabulary: [
                    ("itinerary",     "маршрут/план поездки", "Our itinerary includes three cities."),
                    ("accommodation", "проживание",           "We booked accommodation near the centre."),
                    ("landmark",      "достопримечательность","Big Ben is London's most famous landmark."),
                    ("layover",       "пересадка",            "We have a 2-hour layover in Dubai."),
                    ("departure",     "отправление/вылет",    "The departure is at 6 a.m.")
                ],
                phrases: [
                    ("How do I get to the city centre?",       "Ask for directions in a new city."),
                    ("Could I have a room with a sea view?",   "Make a special hotel request."),
                    ("Is there a direct flight to Paris?",     "Ask about flight options."),
                    ("Where can I exchange currency?",         "Find a place to change money.")
                ],
                tip: "Say 'return ticket' in British English and 'round-trip ticket' in American English — they mean the same thing.",
                realLife: [
                    ("Arriving at a hotel", "At check-in: 'Hi, I have a reservation under [your name].' If you want to request something: 'Would it be possible to get a room on a higher floor / with a quieter view?'"),
                    ("Getting around a new city", "Stop a local and say: 'Excuse me, could you help me? How do I get to [place]?' Then: 'Is it within walking distance?' or 'Should I take the tube/bus?'")
                ]
            )

        case "personal":
            return LessonContent(
                vocabulary: [
                    ("occupation",  "профессия",    "My occupation is software engineering."),
                    ("background",  "происхождение/история", "She has a background in finance."),
                    ("hometown",    "родной город", "My hometown is in the south of Russia."),
                    ("fluent",      "свободно говорящий", "She is fluent in three languages."),
                    ("outgoing",    "общительный",  "He's very outgoing and makes friends easily.")
                ],
                phrases: [
                    ("Nice to meet you! I'm Alex.",           "Standard first introduction."),
                    ("I'm originally from Moscow.",           "Say where you are originally from."),
                    ("What do you do for a living?",          "Ask someone's job politely."),
                    ("I've been living here for two years.",  "Talk about how long you've been somewhere.")
                ],
                tip: "In English, 'How are you?' is usually just a greeting — people don't expect a detailed answer. Just say 'I'm good, thanks!'",
                realLife: [
                    ("Introducing yourself at a social event", "Start with your name and one interesting fact: 'Hi, I'm [name]. I'm originally from Russia but I've been living in [city] for two years. I work in [field]. How about you?'"),
                    ("Responding to 'How are you?'", "Keep it positive and brief: 'I'm good, thanks! And you?' — then listen. If someone asks more deeply, you can say: 'Honestly, it's been a busy week, but I'm doing well.'")
                ]
            )

        case "hobbies":
            return LessonContent(
                vocabulary: [
                    ("passion",      "страсть/увлечение", "Photography is my passion."),
                    ("leisure",      "досуг",             "I enjoy reading in my leisure time."),
                    ("amateur",      "любитель",          "I'm an amateur painter."),
                    ("enthusiast",   "энтузиаст",         "He's a real football enthusiast."),
                    ("spare time",   "свободное время",   "What do you do in your spare time?")
                ],
                phrases: [
                    ("In my spare time, I enjoy hiking.",     "Talk about a hobby casually."),
                    ("I've been getting into cooking lately.","Say you recently started something."),
                    ("Have you ever tried rock climbing?",    "Suggest or ask about a new activity."),
                    ("I'm really into jazz music.",           "Express strong interest in something.")
                ],
                tip: "'Get into' means to start enjoying something. 'I got into podcasts during lockdown' — very natural and common.",
                realLife: [
                    ("Small talk at work or a party", "When asked 'What do you do for fun?': 'In my spare time I'm really into [hobby]. I've been getting into [new thing] lately — it's surprisingly addictive!'"),
                    ("Suggesting a shared activity", "Say: 'Have you ever tried [activity]? You should give it a go — I think you'd love it.' Using 'give it a go' sounds very natural and British.")
                ]
            )

        case "future":
            return LessonContent(
                vocabulary: [
                    ("aspiration",  "стремление",   "Her aspiration is to become a doctor."),
                    ("milestone",   "веха/этап",    "Graduating was a big milestone for me."),
                    ("ambition",    "амбиция",      "He has the ambition to start his own company."),
                    ("pursue",      "стремиться к", "She decided to pursue a career in music."),
                    ("achieve",     "достигать",    "Hard work helps you achieve your goals.")
                ],
                phrases: [
                    ("I'm planning to move abroad next year.",    "Talk about a concrete future plan."),
                    ("My goal is to become fluent in English.",   "State your language learning goal."),
                    ("In five years, I see myself running a business.", "Describe your long-term vision."),
                    ("I hope to travel more once I graduate.",    "Express a wish about the future.")
                ],
                tip: "Use 'I'm going to' for plans already decided, and 'I hope to' or 'I'd like to' for wishes and dreams.",
                realLife: [
                    ("Talking about career goals in an interview", "Say: 'In five years, I see myself taking on more responsibility and hopefully leading a team. My long-term goal is to [specific ambition].'"),
                    ("Talking about personal dreams with a friend", "Use: 'I'm planning to [concrete plan]. Ultimately, I'd love to [bigger dream] — we'll see how it goes!' The casual ending keeps it natural.")
                ]
            )

        default:
            return LessonContent(
                vocabulary: [
                    ("vocabulary", "словарный запас", "Building vocabulary takes daily practice."),
                    ("fluency",    "беглость",        "Fluency comes with consistent practice."),
                    ("grammar",    "грамматика",      "Grammar is the foundation of a language."),
                    ("accent",     "акцент",          "She speaks with a beautiful British accent."),
                    ("phrase",     "фраза",           "Learning phrases is faster than single words.")
                ],
                phrases: [
                    ("Could you repeat that, please?",    "Ask someone to say something again."),
                    ("I don't quite follow — could you explain?", "Politely say you don't understand."),
                    ("How do you say ... in English?",    "Ask for a translation."),
                    ("What does ... mean?",               "Ask for the meaning of a word.")
                ],
                tip: "The best way to improve is to practise a little every day rather than a lot once a week.",
                realLife: [
                    ("When you don't understand something", "Don't pretend to understand — say: 'I'm sorry, could you repeat that?' or 'Could you speak a bit more slowly, please?' Native speakers will always appreciate your honesty."),
                    ("Building your English daily", "Change your phone to English. Watch one short video in English per day. Label things at home in English. Small habits = big results.")
                ]
            )
        }
    }
}

// MARK: - View

struct LessonDetailView: View {
    let card: LessonCard
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var isCompleted = false

    private var content: LessonContent {
        LessonContentProvider.content(for: card.id)
    }

    var body: some View {
        ZStack(alignment: .top) {
            DarkDS.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeader
                    contentBody
                }
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            Color(hex: card.colorHex)

            VStack(alignment: .leading, spacing: 0) {
                // Back button row
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15, design: .rounded))
                        }
                        .foregroundStyle(LotusApp.ink.opacity(0.85))
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 38, height: 38)
                        Image(systemName: card.iconSystemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LotusApp.ink)
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text(card.subtitle.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink.opacity(0.55))
                        .tracking(1.5)
                    Text(card.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(LotusApp.ink)
                    if !card.description.isEmpty {
                        Text(card.description)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(LotusApp.ink.opacity(0.7))
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                    RatingView(rating: card.rating)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
    }

    // MARK: Content Body

    private var contentBody: some View {
        VStack(spacing: 20) {
            lessonPlanCard
            vocabularySection
            phrasesSection
            tipCard
            if !content.realLife.isEmpty {
                realLifeSection
            }
            markCompleteButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .onAppear {
            isCompleted = appState.completedLessonIds.contains(card.id)
        }
    }

    // MARK: Lesson Plan (Figma-style outline with numbered steps)

    private struct LessonStep {
        let number: Int
        let title: String
        let subtitle: String
        let icon: String
        let duration: String
    }

    private var lessonSteps: [LessonStep] {[
        LessonStep(number: 1, title: "Key Vocabulary",   subtitle: "\(content.vocabulary.count) words to learn",  icon: "text.book.closed.fill", duration: "5 min"),
        LessonStep(number: 2, title: "Useful Phrases",   subtitle: "\(content.phrases.count) phrases to practise", icon: "quote.bubble.fill",     duration: "5 min"),
        LessonStep(number: 3, title: "Cultural Tip",     subtitle: "Insight from native speakers",                 icon: "lightbulb.fill",         duration: "2 min"),
        LessonStep(number: 4, title: "Real-life Scenes", subtitle: "\(content.realLife.count) practice scenarios",  icon: "person.2.fill",          duration: "5 min"),
        LessonStep(number: 5, title: "AI Speaking",      subtitle: "Practise with your tutor",                     icon: "waveform.circle.fill",   duration: "10 min"),
    ]}

    private var lessonPlanCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "list.number")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(DarkDS.lime)
                    Text("Lesson Plan")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                }
                Spacer()
                Text(isCompleted ? "Completed" : "~27 min")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isCompleted ? DarkDS.lime : DarkDS.muted)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(isCompleted ? DarkDS.lime.opacity(0.12) : DarkDS.card2))
            }

            // Steps
            VStack(spacing: 0) {
                ForEach(lessonSteps, id: \.number) { step in
                    planRow(step: step)
                    if step.number < lessonSteps.count {
                        // connector line
                        HStack {
                            Rectangle()
                                .fill(DarkDS.border)
                                .frame(width: 1, height: 16)
                                .padding(.leading, 18)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    private func planRow(step: LessonStep) -> some View {
        let done = isCompleted || step.number < 3  // show first steps done if lesson touched
        return HStack(spacing: 14) {
            // Number badge
            ZStack {
                Circle()
                    .fill(done ? DarkDS.lime.opacity(0.15) : DarkDS.card2)
                    .frame(width: 36, height: 36)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DarkDS.lime)
                } else {
                    Text("\(step.number)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
            }

            // Icon + text
            HStack(spacing: 10) {
                Image(systemName: step.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(done ? DarkDS.lime : DarkDS.muted)
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(done ? LotusApp.ink : LotusApp.muted)
                    Text(step.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(DarkDS.muted)
                }
            }

            Spacer()

            Text(step.duration)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DarkDS.muted)
        }
    }

    private var markCompleteButton: some View {
        Button {
            if !isCompleted {
                appState.markLessonComplete(card.id)
                isCompleted = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                Text(isCompleted ? "Lesson Complete! +20 XP" : "Mark as Complete")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(isCompleted ? Color(red: 0.20, green: 0.78, blue: 0.43) : .black)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isCompleted
                          ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.18)
                          : DarkDS.lime)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
        .padding(.bottom, 20)
    }

    // MARK: Vocabulary

    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "text.book.closed.fill", title: "Key Vocabulary")

            ForEach(content.vocabulary, id: \.word) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.word)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(LotusApp.ink)
                        Text("—")
                            .foregroundStyle(DarkDS.muted)
                        Text(item.translation)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(DarkDS.muted)
                    }
                    Text(item.example)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                        .italic()
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))
            }
        }
    }

    // MARK: Phrases

    private var phrasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "bubble.left.and.bubble.right.fill", title: "Useful Phrases")

            ForEach(content.phrases, id: \.english) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text("\"\(item.english)\"")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text(item.note)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: card.colorHex).opacity(0.18))
                )
            }
        }
    }

    // MARK: Tip

    private var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text("Native Speaker Tip")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(content.tip)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15), lineWidth: 1))
        )
    }

    // MARK: Real Life (R8-F)

    private var realLifeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "person.2.fill", title: "Use This In Real Life")

            ForEach(content.realLife, id: \.scenario) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.scenario)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text(item.howTo)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.10))
                )
            }
        }
    }

    // MARK: Section Header

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
        }
    }
}
