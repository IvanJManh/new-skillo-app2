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
                status: "active",
                startedAt: admin.firestore.FieldValue.serverTimestamp(),
                endedAt: null,
            });

        return res.status(201).json({
            success: true,
            sessionId: sessionRef.id,
        });
    } catch (error) {
        console.error("Start session error:", error);
        return res.status(500).json({error: "Failed to start session."});
    }
});

//______________________________________________________________________________________
// POST /api/speaking/analyze
// Flutter sends a base64-encoded audio chunk every few seconds.
// We analyze it and return feedback shown on screen in real time.
//
//Flutter sends:
//  {
//    "sessionId": "xyz",
//    "audioBase64": :"<base64 string>",
//    "skillId": "abc123"
//  }
//  
// Returns:
//  {
//    "success": true,
//    "feedback": [
//      { "type": "peace", "message": "Slow down Your speech!" },
//      ],
//    "transcript": "Hello my name"
//  }
//_______________________________________________________________________________________
router.post("/analyze", verifyToken, async (req, res) => {
    try {
        const {sessionId, audioBase64, skillId} = req.body;
        const userId = req.user.uid;

        if (!audioBase64)
            return res.status(400).json({error: "audioBase64 is required."});
        if (!sessionId)
            return res.status(400).json({error: "sessionId is required."});
        
        // Convert base64 to buffer to send to Google Speech API
        const audioBuffer = Buffer.from(audioBase64, "base64");
        const analysisResult = await analyzeSpeech(audioBuffer);

        //Build human-readable feedback from the analysis numbers
        const feedback = buildFeedback(analysisResult);

        //Save this analysis snapshot to Firestore
        await admin.firestore()
            .collection("practice_sessions")
            .doc(sessionId)
            .collection("speech_analyses")
            .add({
                userId,
                skillId: skillId || null,
                analysis: analysisResult,
                feedback,
                analyzedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        return res.status(200).json({
            success: true,
            feedback,
            transcript: analysisResult.transcript || null,
        });
    } catch (error) {
        console.error("Analyze error:", error);
        return res.status(500).json({error: "Failed to analyze speech."});
    }
});

//_______________________________________________________________________________________
//Post/api/speaking/session/:sessionId/end
//Called when user finishes the practice session.
//Calculates a summary score and marks session as complete.
//
//Flutter sends: nothing (sessionId is in URL)
//
//Returns:
//  { "success": true, "summary": { "fluency": 4, "pronunciation": 3, "overall": 3.5 } }
//_______________________________________________________________________________________
router.post("/session/:sessionId/end", verifyToken, async (req, res) => {
    try {
        const {sessionId} = req.params;
        const userId = req.user.uid;

        const db = admin.firestore();
        const sessionRef = db.collection("practice_sessions").doc(sessionId);
        const sessionSnap = await sessionRef.get();

        if (!sessionSnap.exists) 
            return res.status(404).json({error: "Session not found."});

        if (sessionSnap.data().userId !== userId)
            return res.status(403).json({error: "Unauthorized."});

        // Grab all speech analysis snapshots saved during the session
        const analysesSnap = await sessionIdssionRef.collection("speech_analyses").get();
        const analyses = analysesSnap.docs.map((doc) => doc.data());

        const summary = calculateSummary(analyses);

        await sessionRef.update({
            status: "completed",
            endedAt: admin.firestore.FieldValue.serverTimestamp(),
            summary,
        });

        return res.status(200).jason({ success: true, sessionId, summary });
    } catch (error) {
        console.error("End session error:", error);
        return res.status(500).json({error: "Failed to end session."});
    }
});

//________________________________________________________________________________________
// GET/api/speaking/history
// Returns last 20 speaking sessions for the current user.
// Used to show progress over time in the app.
//
//Returns:
// {"success": true, "sessions": [...]}
//__________________________________________________________________________________________ 
router.get("/history", verifyToken, async (req, res) => {
    try {
        const userId = req.user.uid;

        const snap = await admin.firestore()
            .collection("practice_sessions")
            .where("userId", "==", userId)
            .where("type", "==", "speaking")
            .orderBy("startedAt", "desc")
            .limit(20)
            .get();

        const sessions = snap.docs.map((doc) => ({
            sessionId: doc.id,
            ...doc.data(),
        }));

        return res.status(200).json({ success: true, sessions });
    } catch (error) {
        console.error("History error:", error);
        return res.status(500).json({error: "Failed to fetch history."});
    }
});
//__________________________________________________________________________________________
//Helper: Turn analysis numbers into human-readable feedback messages shown in the app.
//___________________________________________________________________________________________

function buildFeedback (result) {
    const feedback = [];

    if (resul.wordsPerMinute > 160) 
        feedback.push({ type: "pace", message: "Slow down Your speech!" });
    else if (result.wordsPerMinute < 80 && res
        feedback.push({ type: "pace", message: "Try speaking a bit faster!" });

    if (result.volumeLevel ==="low")
        feedback.push({ type: "volume", message: "Speak louder!" });

    if (result.clarityScore <0.5)
        feedback.push({ type: "clarity", message: "Speak more clearly!" });
    )
    if (result.fillWordsCount > 5)
        feedback.push({ type: "fillers", message: "Reduce filler words like 'um', 'uh', etc." });

    if (result.length === 0)
        feedback.push({ type: "Positive", message: "Greate job! Keep it up." });

    return feedback;
}

//___________________________________________________________________________________________
//Helper: Calculate a summary score for the session based on all the analysis snapshots.
//____________________________________________________________________________________________
function calculateSummary(analyses) {
    if (!analyses.length) return {score: 0, totalAnalyses: 0};

    const positiveCount = analyses.fillter(a) =>
    (a.feedback || []).some ((f) => f.type === "positive")
    ).length;

    const score = Math.round((positiveCount / analyses.length) * 100);// Simple percentage of analyses that had positive feedback

    return { score, totalAnalyses: analyses.length };
}

module.exports = router;
