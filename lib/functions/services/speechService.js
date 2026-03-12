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

    const [response] = await client.recognize(request);

    if (!response.result || response.results.length === 0) {
        return emptyResult();
    }

    const transcript = response.results.
        map(result => result.alternatives[0].transcript)
        .join(" ");

    const words = response.results.flatMap(
        result => result.alternatives[0].words || []
    );

    return {
        transcript,
        wordsPerMinute: calculateWordsPerMinute(words),
        clarityScore: calculateClarity(response.results),
        fillerWordCount: countFillerWords(transcript),
        volumeLevel: "normal" //Flutter should measure mic amplitude and send it separately.
        wordCount: words.length,
    };
}

function calculateWordsPerMinute(words) {
    if (!words || words.length < 2) return 0;

    const start = parseFloat(words[0].startTime.seconds || 0);
    const end = parseFloat(words[words.length - 1].endTime.seconds || 0);
    const minutes = (end - start) / 60;

    return minutes === 0 ? 0 : Math.round(words.length / minutes);
}