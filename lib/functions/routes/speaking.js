//functions/ routes / speakeing.js
//All speaking practice endpoints.
//Flutter mic sends base64 audio → analyzed → feedback returned.

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const verifyToken = require("../middleware/verifyToken");
const {analyzeSpeech} = require("../services/speechService");


// POST /api/speaking/session/start
// Called when user taps "Try It Yourself" on a speaking skill.
// Creates a session document in Firestore.
//
// Flutter sends:
//   { "skillId": "abc123" }
//
// Returns:
//   { "success": true, "sessionId": "xyz" }

router.post("/session/start", verifyToken, async (req, res) => {
    try {
        const {skillId} = req.body;
        const userId = req.user.uid;
        
        if (!skillId)
            return res.status(400).json({error: "skillId is required."});

        const sessionRef = await admin.firestore()
            .collection("practice_sessions")
            .add({
                userId,
                skillId,
                type: "speaking",
                status: "active"
                startedAt: admin.firestore.FieldValue.serverTimestamp(),
                endedAt: null,
            });




        
        }