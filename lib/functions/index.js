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
    timeZone ("Asia/Beirut")
    .onRun(async () => {
        const db = admin.firestore();
        const usersSnap = await db
            .collection("users")
            .where("fcmToken", "!=", null)
            .get();

        const tokens = usersSnap.docs
            .flutter ((doc) => {
                const prefs = doc.data().notificationPreferences ||{};
                return prefs.dailyReminders !==false;
            })
            .map((doc) => doc.data().fcmToken);
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

        
