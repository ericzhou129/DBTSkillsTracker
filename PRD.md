# DBT Skills Tracker - PRD

## Purpose
iOS app replicating a paper DBT Skills Used tracking sheet as a digital log.

## Core Requirements
1. **Log skills by day/time** - Tap to log a skill used, with timestamp
2. **Notes per entry** - Add free-text notes to each logged skill use
3. **Export** - Export log as text grouped by day -> skills used + notes
4. **Simple scrollable UI** - Main view is a chronological log: days as sections, skill entries underneath

## Skill Categories (from sheet)
- **Core Mindfulness (CM):** Wise Mind, Observe, Describe, Participate, Nonjudgmental Stance, One-Mindfully, Effectively, Loving Kindness, Balancing Doing Mind and Being Mind, Walking the Middle Path, Pros and Cons of Practicing Mindfulness, Mindfulness of Pleasant Events
- **Interpersonal Effectiveness (IE):** DEAR MAN, GIVE, FAST, Options for Intensity, Pros and Cons of IE Skills, Prioritizing Goals, Troubleshooting IE Skills, Finding and Getting People to Like You, Ending Relationships, Think and Act Dialectically, Self-Validation, Validating Others, Changing Behavior with Reinforcement
- **Emotion Regulation (ER):** Identifying Primary Emotions, Pros and Cons of Changing Emotions, Check the Facts, Opposite to Emotion Action, Problem Solving, Accumulating Positive Emotions (Short Term), Accumulating Positive Emotions (Long Term), Building Mastery, Cope Ahead, PLEASE Skills, Nightmare Protocol, Sleep Hygiene, Mindfulness of Current Emotions, Managing Extreme Emotions, Troubleshooting ER Skills
- **Distress Tolerance (DT):** STOP Skill, Pros and Cons of DT Skills, TIP Skills, Distract with Wise Mind ACCEPTS, IMPROVE the Moment, Body Scan Meditation, Sensory Awareness, Radical Acceptance, Turning the Mind, Willingness, Half-Smiling and Willing Hands, Mindfulness of Current Thoughts
- **DT When Crisis is Addiction:** Reinforcing Non-Addictive Behaviors, Burning Bridges and Building New Ones, Alternate Rebellion, Adaptive Denial

## Tech Stack
- SwiftUI + SwiftData
- iOS 17+ target
- Single-target app, no external dependencies
