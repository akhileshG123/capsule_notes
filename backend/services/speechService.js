const speech = require('@google-cloud/speech');
const client = new speech.SpeechClient();

const transcribeAudio = async (gcsUri) => {
  const request = {
    audio: { uri: gcsUri },
    config: {
      encoding: 'ENCODING_UNSPECIFIED',
      languageCode: 'en-US',
    },
  };

  try {
    const [response] = await client.recognize(request);
    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join('\n');
    return transcription;
  } catch (err) {
    console.error('Speech API Error:', err);
    throw err;
  }
};

module.exports = { transcribeAudio };
