/**
 * Firebase Cloud Functions for LocalGrounds.
 */

const {onRequest} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const OpenAI = require("openai");

setGlobalOptions({maxInstances: 10});

//MY SECRET API KEY
const openAiKey = defineSecret("OPENAI_API_KEY");

//this is a fallback to my ai if im out of tokens
function fallbackAnalysis(text) {
  const lower = text.toLowerCase();

  const positiveWords = ["great", "good", "amazing", "love", "nice"];
  const negativeWords = ["bad", "terrible", "awful", "hate", "loud"];

  let score = 0;
  for (const w of positiveWords) {
    if (lower.includes(w)) score += 1;
  }
  for (const w of negativeWords) {
    if (lower.includes(w)) score -= 1;
  }

  let sentiment = "neutral";
  if (score > 0) sentiment = "positive";
  if (score < 0) sentiment = "negative";

  const tags = [];
  if (lower.includes("outlet")) tags.push("many-outlets");
  if (lower.includes("loud")) tags.push("loud");
  if (lower.includes("quiet")) tags.push("quiet");
  if (lower.includes("cold brew")) tags.push("cold-brew");
  if (lower.includes("wifi") || lower.includes("wi-fi")) tags.push("good-wifi");
  if (lower.includes("study") || lower.includes("studying")) {
    tags.push("study-friendly");
  }

  let summary = text.trim();
  if (summary.length > 140) {
    summary = summary.slice(0, 137) + "...";
  }

  return {summary, sentiment, tags};
}

/**
 * AI endpoint: analyzeCafeNote
 * POST { "text": "user's note..." }
 * Returns JSON: { summary, sentiment, tags }
 */
exports.analyzeCafeNote = onRequest(
  {secrets: [openAiKey]},
  async (req, res) => {
    // CORS
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    if (req.method === "OPTIONS") {
      return res.status(204).send("");
    }

    if (req.method !== "POST") {
      return res.status(405).send({error: "Only POST allowed"});
    }

    let text = "";

    try {
      const apiKey = openAiKey.value();
      if (!apiKey) {
        logger.error("Missing OPENAI_API_KEY secret");
        return res.status(500).send({error: "Server misconfigured"});
      }

      const client = new OpenAI({apiKey});
      const body = req.body || {};
      text = body.text;

      if (!text || typeof text !== "string") {
        return res.status(400).send({
          error: "Missing 'text' string in request body",
        });
      }
//prompt to give open ai to do analysis on my notes
      const prompt = `
You are analyzing notes about coffee shops.

Return STRICT JSON ONLY.
Do not include any markdown, code fences, backticks, or explanation text.
Return exactly this structure and nothing else:

{
  "summary": "1-2 sentence summary",
  "sentiment": "positive | neutral | negative",
  "tags": ["short", "kebab-case", "tags"]
}

Note:
"""${text}"""
`;

//call openai for response
      const completion = await client.responses.create({
        model: "gpt-4.1-mini",
        input: prompt,
        max_output_tokens: 256,
      });

      let rawText = completion.output[0].content[0].text;

      let cleaned = rawText.trim();
      const start = cleaned.indexOf("{");
      const end = cleaned.lastIndexOf("}");
      if (start !== -1 && end !== -1 && end > start) {
        cleaned = cleaned.slice(start, end + 1);
      }

      let parsed;
      try {
        parsed = JSON.parse(cleaned);
      } catch (parseErr) {
        logger.error("Failed to parse model output as JSON:", rawText);
        const backup = fallbackAnalysis(text);
        return res.status(200).json(backup);
      }

      const result = {
        summary: parsed.summary || "",
        sentiment: parsed.sentiment || "neutral",
        tags: Array.isArray(parsed.tags) ? parsed.tags : [],
      };

      return res.status(200).json(result);
    } catch (err) {
      logger.error("Error in analyzeCafeNote:", err);
      const message = err.message || String(err);

//if my quotas been exceeded use the fallback
      if (message.includes("429")) {
        const backup = fallbackAnalysis(text || "");
        return res.status(200).json(backup);
      }

      return res.status(500).json({
        error: "AI processing failed",
        message,
      });
    }
  }
);
