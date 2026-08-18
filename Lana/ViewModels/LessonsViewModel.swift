import Foundation
import Combine

final class LessonsViewModel: ObservableObject {
    @Published var featuredStack: [LessonCard] = []
    @Published var lessons: [LessonCard] = []
    @Published var selectedTab: LessonTab = .practice

    init() {
        // Stacked deck cards (last = front card on top)
        featuredStack = [
            LessonCard(id: "stack1", title: "Favorite TV Series",   subtitle: "Talk about your favorite shows",   description: "", rating: 5, colorHex: "#BFEBD9", iconSystemName: "tv"),
            LessonCard(id: "stack2", title: "Work & Career",        subtitle: "Discuss job roles",                description: "", rating: 3, colorHex: "#F2B4D6", iconSystemName: "briefcase"),
            LessonCard(id: "stack3", title: "Health Care",          subtitle: "Talk about healthy lifestyle",     description: "", rating: 4, colorHex: "#A7B4F5", iconSystemName: "leaf"),
            LessonCard(id: "stack4", title: "Food & Cooking",       subtitle: "Share your favorite dishes",      description: "", rating: 4, colorHex: "#F3D065", iconSystemName: "fork.knife"),
            LessonCard(id: "stack5", title: "Personal Information", subtitle: "Introduce yourself",              description: "", rating: 5, colorHex: "#E3B3E8", iconSystemName: "person.crop.circle"),
            LessonCard(id: "stack6", title: "Places to Visit",      subtitle: "Describe travel experiences",     description: "", rating: 4, colorHex: "#8DD896", iconSystemName: "airplane"),
            LessonCard(id: "stack7", title: "Your Hobbies",         subtitle: "Talk about what you like",        description: "", rating: 3, colorHex: "#7EC5E8", iconSystemName: "paintbrush"),
            LessonCard(id: "stack8", title: "Future Plans",         subtitle: "Speak about your goals",          description: "", rating: 4, colorHex: "#E7C96B", iconSystemName: "globe.europe.africa"),
            LessonCard(id: "stack9", title: "Culture & Holidays",   subtitle: "Describe celebrations",           description: "", rating: 4, colorHex: "#C7D6F2", iconSystemName: "sparkles")
        ]

        // Scrollable lesson cards
        lessons = [
            LessonCard(
                id: "health",
                title: "Health Care",
                subtitle: "Health & Fitness",
                description: "Talk about personal health, fitness and healthy lifestyle choices, and nutritional diet menus",
                rating: 2,
                colorHex: "#A7B4F5",
                iconSystemName: "stethoscope"
            ),
            LessonCard(
                id: "tv",
                title: "Favorite TV Series",
                subtitle: "Entertainment",
                description: "You can discuss your favorite shows, their genres and actors. Talk about what scenes are most memorable and why",
                rating: 3,
                colorHex: "#BFEBD9",
                iconSystemName: "tv"
            ),
            LessonCard(
                id: "food",
                title: "Food & Cooking",
                subtitle: "Daily Life",
                description: "Share your favorite dishes, recipes, and discuss cuisines of the world and swap cooking tips",
                rating: 4,
                colorHex: "#F3D065",
                iconSystemName: "fork.knife"
            ),
            LessonCard(
                id: "work",
                title: "Work & Career",
                subtitle: "Professional",
                description: "Share your professional background, talk about job roles, and discuss career aspirations",
                rating: 3,
                colorHex: "#F2B4D6",
                iconSystemName: "briefcase"
            ),
            LessonCard(
                id: "travel",
                title: "Places to Visit",
                subtitle: "Travel",
                description: "Describe travel experiences, talk about must-see destinations and plan dream trips",
                rating: 4,
                colorHex: "#8DD896",
                iconSystemName: "airplane"
            ),
            LessonCard(
                id: "personal",
                title: "Personal Information",
                subtitle: "Introduction",
                description: "Introduce yourself, talk about where you're from, your family, and your daily routine",
                rating: 5,
                colorHex: "#E3B3E8",
                iconSystemName: "person.crop.circle"
            ),
            LessonCard(
                id: "hobbies",
                title: "Your Hobbies",
                subtitle: "Interests",
                description: "Talk about what you enjoy doing in your free time, sports, art, music, and reading",
                rating: 3,
                colorHex: "#7EC5E8",
                iconSystemName: "paintbrush"
            ),
            LessonCard(
                id: "future",
                title: "Future Plans",
                subtitle: "Goals",
                description: "Speak about your goals, dreams, and plans for the near and distant future",
                rating: 4,
                colorHex: "#E7C96B",
                iconSystemName: "globe.europe.africa"
            )
        ]
    }
}

enum LessonTab: String, CaseIterable {
    case practice = "Practice"
    case lessons  = "Lessons"
}
