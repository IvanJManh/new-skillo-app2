// functions/routes/notifications.js
//All notification endpoints.
//Flutter saves its FCM token here. Server sends push notifications.

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const verifyToken = require("../middleware/verifyToken");

//______________________________________________________________________________________________
// POST /api/notifications/token
// Flutter calls this right after login to save the device token.
//Without this, the user won't receive any push notifications.
//
// How to get the token is Flutter:
//   final token = await FirebaseMessaging.instance.getToken();
//   
// Flutter sends:
//   { "fcmToken": "eXYZ123..." }

Returns:
//   { "success": true }
//______________________________________________________________________________________________
router.post("/token", verifyToken, async (req, res) => {
    try {
        const {fcmToken} = req.body;
        const userId = req.user.uid;
        
        if (!fcmToken)
            return res.status(400).json({error: "fcmToken is required."});

        //Save token to the user's Firestore document.
        //merge: true so we don't overwrite other user fields.
        await admin.firestore().collection("users".doc(userId)).set(
            {
                fcmToken,
                fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            {merge: true}
        );

        return res.status(200).json({success: true});
    } catch (error) {
        console.error("Save token error:", error);
        return res.status(500).json({error: "Failed to save token."});
    }
});

//______________________________________________________________________________________________
//DELETE/api/notifications/token
//Flutter calls this on lohout so user stops getting notifications.
//
//Flutter sends: nothing (user identified by Bearer token)
//
//Returns:
//  { "success": true }
//______________________________________________________________________________________________
router.delete("/token", verifyToken, async (req, res) => {
    try {
       await admin.firestore().collection("users").doc(req.user.uid).update({
            fcmToken: admin.firestore.FieldValue.delete(),
       });

        return res.status(200).json({success: true});
    } catch (error) {
        console.error("Delete token error:", error);
        return res.status(500).json({error: "Failed to remove token."});
    }   
});

//______________________________________________________________________________________________
//GET/api/notifications/preferences
//Flutter calls this to load the user's settings screens. It can also be used to check if notifications are enabled.

//Returns:
//  { 
// "success": true,
// "preferences":  {
//    "dailyReminder": true,
//    "streakAlerts": true,
//    "achievements": true
//  }
// }
//______________________________________________________________________________________________
router.get("/preferences", verifyToken, async (req, res) => {
    try {
        const doc = await admin.firestore()
            .collection("users")
            .doc(req.user.uid)
            .get();

        if (!doc.exists) 
            return res.status(404).json({error: "User not found."});

        //Default all preferences to true if not set
        const preferences = doc.data().notificationPreferences || {
            dailyReminder: true,
            streakAlerts: true,
            achievements: true,
        };

        return res.status(200).json({success: true, preferences});
    } catch (error) {
        console.error("Get preferences error:", error);
        return res.status(500).json({error: "Failed to get preferences."});
    }
});

//______________________________________________________________________________________________
//PUT/api/notifications/preferences
//Flutter settings screen calls this to update the user's notification preferences.
//
//Flutter sends:
//  {
//    "dailyReminder": true,
//    "streakAlerts": false,
//    "achievements": true
//  }
//
//Returns:
//  { "success": true }
//______________________________________________________________________________________________
router.put("/preferences", verifyToken, async (req, res) => {
    try {
        const {dailyReminder, streakAlerts, achievements} = req.body;

        await admin.firestore().collection("users").doc(req.user.uid).set(
            {
                notificationPreferences: {
                    dailyReminder: dailyReminder ?? true,
                    streakAlerts: streakAlerts ?? true,
                    achievements: achievements ?? true,
                },
            },
            {merge: true}
        );

        return res.status(200).json({success: true});
    } catch (error) {
        console.error("Update preferences error:", error);
        return res.status(500).json({error: "Failed to update preferences."});
    }
});

module.exports = router;
