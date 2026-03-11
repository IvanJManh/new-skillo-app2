// functions/middleware/verifyToken.js
// Verifies the Firebase ID token Flutter sends in every request.
// Flutter sends it as:  Authorization: Bearer <idToken>
// Get the idToken in Flutter with:
//   final token = await FirebaseAuth.instance.currentUser?.getIdToken();
