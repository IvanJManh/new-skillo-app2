Skillo – Two Minute Daily Skill Learning App
Overview

Skillo is a mobile application designed to help users improve everyday life skills through short daily learning sessions. The app provides 2-minute skill videos and allows users to practice the skill immediately using their device’s camera and microphone.

The goal of Skillo is to promote daily self-improvement through micro-learning and AI-powered feedback.

Example skills include:
Reading facial expressions
Maintaining eye contact
Improving posture
Communication techniques
Body language awareness

Each skill is designed to be simple, practical, and interactive.

Core Concept
The user logs into the app.
The Home Screen displays:
A daily skill video card
And a Current learning streak card

The user selects and watches a 2-minute skill video.

After watching the video, a “Try It Yourself” button appears.

When the user presses the button:

The front camera is activated

The microphone is activated

The user practices the skill in real time.

The app uses AI APIs to analyze the user's behavior and display feedback messages on the screen.

Example feedback messages:
“Try to maintain better eye contact.”
“Keep your posture straight.”
“Relax your facial muscles.”
“Speak more clearly.”

This creates an interactive learning experience instead of passive video watching.

Main Features
1. User Authentication

Users must create an account or log in to access the application.

Functions:
User registration
Login
Logout
User profile

2. Daily Skill System

Each day the app provides two skill videos.

The Home Screen displays:
Skill Card 1
Current streak

Each skill card includes:
Skill title
Skill thumbnail
Skill description
Skill video

3. Video Learning

Users watch a short 2-minute tutorial video explaining a specific skill.

Examples:
How to read facial expressions
How to maintain eye contact
How to improve posture

After the video ends, a button appears:

Try It Yourself

4. Practice Mode

When the user clicks Try It Yourself:

The application will:
Open the front camera
Activate the microphone

The user can then practice the skill while being observed by the system.

5. AI Feedback System

The app integrates AI APIs to analyze user behavior in real time.
The AI provides on-screen feedback messages while the user practices.

Example feedback:

Facial Expression Training:
“Try to maintain eye contact.”
“Relax your eyebrows.”

Posture Training:
“Keep your shoulders straight.”
“Sit upright.”

Speaking Practice:
“Speak louder.”
“Slow down your speech.”

6. Streak Tracking

The app tracks daily learning consistency.

Users build streaks by completing daily skills.


Example:

Day 1 → Streak = 1

Day 5 continuous learning → Streak = 5

This encourages users to practice skills every day.


Application Flow

User Login
↓
Home Screen (Daily Skills + Streak)
↓
User selects skill video
↓
User watches video
↓
User clicks Try It Yourself
↓
Camera and microphone are activated
↓
User practices the skill
↓
AI analyzes behavior
↓
Real-time feedback displayed


Example Use Case

Skill: Reading Facial Expressions

Step 1
User watches a 2-minute tutorial video.

Step 2
User presses Try It Yourself.

Step 3
The front camera opens.

Step 4
User practices facial expressions.

Step 5
AI analyzes:
Eye movement
Face posture
Facial expressions


Step 6
Feedback appears on the screen such as:
“Try to smile naturally.”
“Maintain eye contact.”

Technologies Used
Frontend
Flutter

Backend
Node.js / Firebase

AI Integration
Computer Vision APIs
Facial Expression Detection APIs
Speech Recognition APIs

Database
Firebase Firestore / MongoDB
Cloud Storage
Firebase Storage

Example Project Structure
skillo-app
│
├── frontend
│   ├── screens
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── skill_video_screen.dart
│   │   └── practice_screen.dart
│   │
│   ├── widgets
│   └── services
│
├── backend
│   ├── api
│   ├── ai_integration
│   └── database
│
└── assets
    ├── videos
    └── images
Future Improvements

Possible future features include:
Personalized skill recommendations
Skill progress tracking
Difficulty levels for skills
AI performance scoring
Leaderboards
Social sharing

Project Goal

The goal of Skillo is to help users develop useful life skills in just two minutes a day through interactive practice and AI-driven feedback, making skill learning simple, fast, and engaging.
