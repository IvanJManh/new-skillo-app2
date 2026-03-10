//functions/ routes / speakeing.js
//All speaking practice endpoints.
//Flutter mic sends base64 audio → analyzed → feedback returned.

const express = require("express");
const router = express.Router();
const admin = require("firebase-admin");
const verifyToken = require("../middleware/verifyToken");
const {analyzeSpeech} = require("../services/speechService");

// POST /speaking/practice