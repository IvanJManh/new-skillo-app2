// functions/middleware/verifyToken.js
// Verifies the Firebase ID token Flutter sends in every request.
// Flutter sends it as:  Authorization: Bearer <idToken>
// Get the idToken in Flutter with:
//   final token = await FirebaseAuth.instance.currentUser?.getIdToken();

const admin = require("firebase-admin");

async function verifyToken(req, res, next) {
    try{
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return res.status(401).json({error: "No token provided."});
        }

        const token = authHeader.split(" ")[1];
        decoded = await admin.auth().verifyIdToken(token);

        req.user = decoded; // req.user.vaild is now available in all routes. 
        next();
    } catch (error) {
        return res.status(401).json({error: "Invalid or expired token."});
    }
}

module.exports = verifyToken;