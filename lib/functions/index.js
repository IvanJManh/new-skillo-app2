//function/index.js
//Entry point-exports all Firebase Cloud Functions

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const app = express();

// Initialize Firebase Admin
admin.initializeApp();
app.use(express.json({limit: "10mb"})); //10mb for base64 audio

// Import routes
const speackingRoutes = require("./routes/speacking");
const notificationRoutes = require("./routes/notifications");

app.use("/speacking", speackingRoutes);
app.use("/notifications", notificationRoutes);

//Health check
app.get("/", (req, res) => res.json({ status: "Skillo backend running."}));

//Export as Firebase HTTPS Function
exports.api = functions.https.onRequest(app);

// Scheduled Functions (Corn Jobs)
exports.dailyReminder = functions.pubsub
    .schedule("0 9 * * *") // Every day at 9:00 AM  
    .timeZone ("Asia/Beirut")
    .onRun(async () => {
        const db = admin.firestore();
        const usersSnap = await db
            .collection("users")
            .where("fcmToken", "!=", null)
            .get();

        const tokens = usersSnap.docs
            .filter ((doc) => {
                const prefs = doc.data().notificationPreferences ||{};
                return prefs.dailyReminders !==false;
            })
            .map((doc) => doc.data().fcmToken)
            .filter (Boolean); // Remove null/undefined tokens

            if (!tokens.length) return null;

            await admin.messaging().sendEachForMulticast({
                tokens,
                notification: {
                    title: "⚡ Your Daily Skill is Ready!",
                    body: "2 minutes a day builds better habits. Practice now!",
                },
                data: {screen: "home", type: "daily_reminder"},
            });

            return null;
        });

exports.streakAlert = functions.pubsub
    .schedule("0 20 * * *") // Every day at 8:00 PM
    .timeZone("Asia/Beirut")
    .onRun(async () => {
        const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
        const db = admin.firestore();

        const usersSnap = await db
            .collection("users")
            .where("fcmToken", "!=", null)
            .get();

        const usersToAlert = usersSnap.docs
            .map ((doc) => ({ id: doc.id, ...doc.data() }))
            .filter((u) => {
                const prefs = u.notificationPreferences || {};
                return (
                    prefs.streakAlerts !== false &&
                    u.Streak > 0 &&
                    u.lastCompletedDate !== today
                );
            });
            
const sends = usersToAlert.map((u) =>
    admin.messaging().send({
        token: u.fcmToken,
        notification: {
            title: "🔥 Don't Break Your Streak!",
            body: `You're on a ${u.streak}-day streak. Complete today's skill before midnight!`,
        },
        data: { screen: "home", type: "streak_alert" },
    })
);

await Promise.allSettled(sends);
return null;
});