//fuctions/srvices/speechService.js
//Wrap Google Cloud Speech-to-Text.
//Called by speaking.js to analyze audio buffers from Flutter.

const speech = require("@google-cloud/speech");
const client = new speech.SpeechClient();

/**
 * Analyze an audio buffer and return speech metrics.
 * @param {Buffer} audioBuffer - Raw audio from Flutter mic(base64 decoded).
 * @return {{transcript, wordsPerMinute, clarityScore, fillerWordCount, volumeLevel}}
 */
async function analyzeSpeech(audioBuffer) {
    const request = {
        audio: {
            content: audioBuffer.toString("base64"),
        },
        config: {
            encoding: "WEBM_OPUS", //Default for Flutter mic input. Adjust if using different audio source.
            sampleRateHertz: 16000,
            languageCode: "en-US",
            enableWordTimeOffsets: true, //Needed to calculate words per minute and clarity.
            enableAutomaticPunctuation: true,
        },
    };