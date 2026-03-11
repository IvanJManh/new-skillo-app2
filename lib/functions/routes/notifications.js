// functions/routes/notifications.js
//All notification endpoints.
//Flutter saves its FCM token here. Server sends push notifications.

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const verifyToken = require("../middleware/verifyToken");

//______________________________________________________________________________________________
// POST /api/notifications/token