const vision = require('@google-cloud/vision');
const client = new vision.ImageAnnotatorClient();

const extractText = async (gcsUri) => {
  try {
    const [result] = await client.textDetection(gcsUri);
    const detections = result.textAnnotations;
    if (detections && detections.length > 0) {
      return detections[0].description;
    }
    return '';
  } catch (err) {
    console.error('Vision API Error:', err);
    throw err;
  }
};

module.exports = { extractText };
