require("dotenv").config();
// functions/index.js
const functions = require("firebase-functions");
const { VertexAI } = require("@google-cloud/vertexai");

const vertexAI = new VertexAI({
  project: process.env.GCP_PROJECT_ID,
  location: process.env.GCP_LOCATION,
});

const model = vertexAI.preview.getGenerativeModel({
//  model: "gemini-2.5-flash"
//  model: "gemini-2.5-flash-preview-04-17"
  model: process.env.GEMINI_MODEL_NAME,
});

exports.getFunFact = functions.https.onRequest(async (req, res) => {
//  const { latitude, longitude } = req.body;
//  if (!latitude || !longitude) {
//    res.status(400).send("緯度経度が必要です");
//    return;
//  }
//
//    const prompt = ` あなたは町の音声ガイドです。緯度${latitude}、経度${longitude}の場所について、面白い歴史
//的または地理的な雑学、周辺のおすすめなどを日本語で短く教えてください。緯度経度を聞いてもわからないので緯度経
//度は言わないで地名で教えてください。連続で話すので、承知しましたなどはいらないです。`;
//

  const { placeName } = req.body;
  if (!placeName) {
    res.status(400).send("地名(placeName)が必要です");
    return;
  }

  const prompt = `あなたは町の音声ガイドです。「${placeName}」について、面白い歴史的または地理的な雑学、周辺のおすすめなどを日本語で短く教えてください。`;

  try {
    const result = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
    });

    console.log("=== Gemini result ===");
    console.log(JSON.stringify(result, null, 2));

    const text = result?.response?.candidates?.[0]?.content?.parts?.[0]?.text ?? "情報が取得できませんでした。";
   // const text = result?.candidates?.[0]?.content?.parts?.[0]?.text ?? "情報が取得できませんでした。";
    res.status(200).json({ funfact: text });
  } catch (error) {
    console.error("Gemini API エラー:", error);
    res.status(500).send("Gemini処理に失敗しました");
  }
});
