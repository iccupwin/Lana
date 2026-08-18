# Home Screen Competitive Audit
### Language Learning App UX Research — March 2026

---

## App-by-App Summary

### 1. Duolingo ★★★★★
- **CTA**: The ENTIRE screen IS the CTA — a vertical skill path of tappable nodes. No separate "continue" button needed; the path is the navigation.
- **Progress**: Streak flame (top-left), XP gem count (top-center), hearts (top-right), plus a daily goal ring overlay. Four stats always visible.
- **Navigation**: Bottom tabs: Learn · Practice · Leaderboard · Profile. Learn = path map.
- **Habit loop**: "You have a streak to protect!" push notifications. Streak freeze as IAP. Weekly league with promotion/demotion stakes.
- **Content layout**: Scrollable path of circular nodes connected by a winding line. Completed = filled, current = pulsing ring, locked = gray lock.
- **Motivation**: Streak flame, league rank (Bronze → Diamond → Obsidian), milestone chests, friend activity feed.
- **Personalization**: Greeting with name, CEFR level label, "You're on a 7-day streak!" banners.

### 2. Babbel ★★★★
- **CTA**: One prominent "Continue Lesson" card at the top — full-width, gradient background, lesson title visible. Below: "Review" secondary button.
- **Progress**: Horizontal progress bar per course unit (e.g., "Unit 3 of 8"). No global XP — pure content progress.
- **Navigation**: Tab bar: Learn · Review · My Babbel · Profile.
- **Habit loop**: Daily reminder based on chosen learning goal (5/10/15 min/day). Streak shown in "My Babbel" profile.
- **Content layout**: Course units as stacked cards. Tap to expand → lesson list.
- **Motivation**: Less gamified than Duolingo; relies on content quality and real-world usefulness framing.
- **Personalization**: "Pick up where you left off" with last lesson title. Language goal displayed prominently.

### 3. Busuu ★★★★
- **CTA**: "Continue studying" button + "My day at a glance" section showing XP earned today.
- **Progress**: Daily XP goal ring (like Apple Watch fitness rings). Weekly XP chart.
- **Navigation**: Bottom tabs: Learn · Vocabulary · Community · Profile.
- **Habit loop**: "My day at a glance" widget showing XP goal + words reviewed + corrections pending.
- **Content layout**: Course path with chapter tiles. Community tab shows native speaker corrections.
- **Motivation**: Native speaker corrections as social proof. "X people are studying right now." Friend leaderboard.
- **Personalization**: Grammar review based on past mistakes. "Recommended for you" based on weak areas.

### 4. Rosetta Stone ★★★
- **CTA**: "Continue" button for the current unit lesson. Very prominent at top.
- **Progress**: Unit completion percentage (circular badge per unit). Overall course progress bar at top.
- **Navigation**: Tab bar: Learn · Phrasebook · Stories · Profile.
- **Habit loop**: Phrasebook "Tip of the Day." Progress milestone emails. Pronunciation accuracy score.
- **Content layout**: Grid of units → tap to see lessons within. Clean, minimal cards.
- **Motivation**: "TruAccent" pronunciation badges. Completion certificates.
- **Personalization**: Adaptive review based on pronunciation accuracy. "Focus areas" showing weak topics.

### 5. Pimsleur ★★★
- **CTA**: Single "Play Lesson" button — extremely prominent, center screen. Nothing else competes with it.
- **Progress**: Lesson number and series (e.g., "English Level 1, Lesson 12"). No XP or streaks.
- **Navigation**: Very simple — Today's lesson + browse library + profile.
- **Habit loop**: "30 minutes a day" framing. Calendar dot showing completion each day.
- **Content layout**: Horizontal lesson cards for browsing. Audio-first, minimal UI.
- **Motivation**: Calendar completion visualization. Achievement emails for completing levels.
- **Personalization**: Adaptive recall — reintroduces vocabulary user struggled with.

### 6. Lingoda ★★★
- **CTA**: "Book a class" — scheduler-focused. Live class times as the home content.
- **Progress**: Classes completed this month, sprint progress.
- **Navigation**: Classes · Library · Progress · Account.
- **Habit loop**: Sprint challenges (30 classes in 30 days) with money-back guarantees.
- **Content layout**: Calendar view of available classes. Time-slot cards for booking.
- **Motivation**: Sprint rewards ($50–$200 cashback). Teacher profile photos create accountability.
- **Personalization**: Teacher recommendations based on past ratings. Preferred class time memory.

### 7. Preply ★★★
- **CTA**: "Schedule a lesson" or "Message your tutor." Tutor relationship is the product.
- **Progress**: Hours studied with each tutor. Vocabulary flashcard decks built from lessons.
- **Navigation**: Sessions · Explore · Vocabulary · Profile.
- **Habit loop**: Next scheduled session countdown on home screen. "Don't let your tutor down" framing.
- **Content layout**: Tutor avatar + next session time as hero card. Self-study vocab below.
- **Motivation**: Tutor accountability. Progress reports sent to user via email/in-app.
- **Personalization**: Strong — tutor remembers goals, weak points. Lesson history visible.

### 8. Cake (English) ★★★★
- **CTA**: "Today's Video" — Netflix-style hero card at top with thumbnail, title, and duration chip.
- **Progress**: Streak + daily goal (simple checkboxes). Level badge.
- **Navigation**: Home · Explore · My Words · Profile (bottom tab).
- **Habit loop**: "Daily video" as anchor habit. "Review yesterday's expressions" reminder.
- **Content layout**: Horizontal scroll rows for categories (Beginner, Business, Slang). Each row: video cards.
- **Motivation**: Word collection ("My Words" tab). Expression review. Stars for completing exercises.
- **Personalization**: Recommended videos based on watch history. Level filtering.

### 9. ELSA Speak ★★★★
- **CTA**: Daily mission / "Continue Practice" button — prominent with phoneme accuracy score.
- **Progress**: Pronunciation accuracy percentage as the primary KPI. Daily mission ring (3 activities).
- **Navigation**: Home · Practice · Progress · Profile.
- **Habit loop**: 3 daily missions (mandatory before free practice). Streak counter.
- **Content layout**: Mission cards with clear title, duration, and XP. Progress ring per mission.
- **Motivation**: Pronunciation accuracy % improvement over time. Certificate of completion.
- **Personalization**: Weak phoneme detection → targeted exercises. AI accent coach feedback.

### 10. Clozemaster ★★
- **CTA**: "Play" button per language pair — minimal, text-heavy.
- **Progress**: Percentage "mastered" per skill. Score and fluency fast track %.
- **Navigation**: Very flat — language selector → topic → play.
- **Habit loop**: Daily listening/reading streaks. Automated spaced repetition.
- **Content layout**: Dense list of topics/sentence packs. Not visual.
- **Motivation**: Leaderboard for sentences completed. Mastery % graphs.
- **Personalization**: Difficulty adapts automatically. Smart review queue.

---

## TOP 5 Patterns Worth Adopting

### 1. Duolingo — Visual Skill Path Preview on Home Screen
**Why**: Replaces abstract "continue" text with a tangible, spatial sense of progress. Seeing completed nodes (filled) vs. current (pulsing) vs. locked gives the user an immediate orientation of "where I am" in the curriculum. Creates FOMO — the locked nodes are aspirational.
**Implement as**: Horizontal scrollable row of 5–6 circular nodes per world, connected by a line. Shows the current world + 1–2 nodes back and forward.

### 2. ELSA — Daily Goal Ring (Prominent, Not Hidden)
**Why**: ELSA's daily ring is the first thing you see — large, centered, with percentage text. This creates a clear daily completion loop. Duolingo buries the ring in the top bar; ELSA makes it the hero. Users who see a ring at 60% are psychologically compelled to complete it.
**Implement as**: A dedicated "Today's Goal" card with a 80pt ring showing XP / daily goal, plus a motivational label.

### 3. Babbel — "Continue Lesson" Hero Card
**Why**: One clear, unambiguous primary action. Babbel's hero card shows exactly what lesson you'll continue, with a gradient background that demands attention. No confusion about what to do next.
**Implement as**: Full-width card with blue gradient, "PICK UP WHERE YOU LEFT OFF" label, lesson title, world progress, and a large "Continue →" button.

### 4. Busuu — "My Day at a Glance" Summary Widget
**Why**: A compact stats row showing today's XP earned, words reviewed, and quests completed. Gives the user a sense of accomplishment even before they do anything new. Also serves as a social nudge ("You've done X today").
**Implement as**: Three-column stat row inside the hero card: XP today / streak / words saved.

### 5. Duolingo/Busuu — Weekly League with Stakes
**Why**: The leaderboard creates urgency ("promotion/demotion zones") and social competition. Even mock leaderboards (simulated opponents) drive significant engagement. The tier system (Bronze → Diamond) creates long-term aspiration.
**Implement as**: Compact "League" widget showing top 3 players as a mini podium + user's current rank and XP, with a "View League" CTA.

---

## TOP 3 Patterns to AVOID

### 1. Lingoda / Preply — Session Scheduling as Primary CTA
**Why**: Only relevant for live-class apps. For self-paced learning, a calendar/booking UI on home adds cognitive load and creates friction before any learning happens. Users who open the app impulsively (the highest-value moment) are stopped by scheduling decisions.

### 2. Clozemaster — Dense Text-Heavy Layout
**Why**: Small font, table-like lists, and percentage numbers overwhelm casual learners. Works for power users but creates intimidation for B1 and below. The home screen should feel inviting and achievable, not like a spreadsheet.

### 3. Babbel — Zero Gamification
**Why**: Babbel deliberately avoids XP and streaks, betting on intrinsic motivation. Data from Duolingo and ELSA shows that gamification (streaks, XP, leagues) significantly increases Day-7 and Day-30 retention for language apps. Avoiding it is a design philosophy choice, but not the right one for a mass-market app.

---

## Component-by-Component Design Decisions

| Component | Winner | Source | Key Detail |
|-----------|--------|--------|------------|
| **Header** | Compact stat bar | Duolingo | Streak + app logo + hearts + daily ring. Always sticky. ≤56pt height. |
| **Greeting** | Name + time-based text | Babbel/Busuu | "Good morning, Alex" + motivational subtext. Card form with level badge. |
| **Streak counter** | Flame + days + weekly dots | Duolingo | Orange flame icon, day count (bold), 7 dots for this week. |
| **Daily goal** | Prominent ring card | ELSA | 80pt ring, XP/goal text, motivational label. Separate card, not just in top bar. |
| **Continue lesson** | Hero gradient card | Babbel | Full-width, blue gradient, lesson name, progress, big play button. |
| **Skill path** | Horizontal node preview | Duolingo | 5–6 nodes, connected line, completed/current/locked states. |
| **Quick practice** | Horizontal chip row | Cake | Icon + label chips in ScrollView. 6 activity types. |
| **Leaderboard** | Podium widget | Busuu/Duolingo | Top 3 podium + user rank. "View Full Leaderboard" link. |
| **Bottom tab bar** | 4 labeled tabs | Babbel/Pimsleur | Home · Practice · Progress · Profile. Always label icons — icon-only failed in Duolingo UX audits. |

---

## Quantitative Benchmarks (Research-Validated)

| Metric | Source | Value |
|--------|--------|-------|
| Streaks increase commitment | Duolingo | +60% |
| 7-day streak → long-term retention | Duolingo | 3.6× more likely to stay |
| Streak freeze reduces at-risk churn | Duolingo | −21% churn |
| XP leaderboards → lesson completions | Duolingo | +40% per week |
| League system → lesson completion | Duolingo | +25% |
| Badge system → completion rate | Duolingo | +30% |
| Optimal daily session length | ELSA/Duolingo | 5–7 minutes |
| Duolingo DAUs (2025) | Public | 34M |
| Cake total users | Public | 100M+ |
| App Store ratings (top apps) | App Store | 4.7–4.8 ★ |

## Lana — Already Implemented Patterns ✅

| Pattern | Status |
|---------|--------|
| Sticky top bar (streak + hearts + daily ring) | ✅ Done |
| Streak freeze mechanic | ✅ Done |
| XP leaderboard/league | ✅ Done |
| Daily missions (3 quests) | ✅ Done |
| Skill path (QuizMapView) | ✅ Done |
| Labeled bottom tabs | ✅ Done |
| Streak-based motivational messages | ✅ Done |
| XP float animation on correct answer | ✅ Done |
