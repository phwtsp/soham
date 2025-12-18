
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export async function getMindfulTip() {
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: 'Give a one-sentence mindfulness tip for a busy day.',
      config: {
        systemInstruction: "You are a zen meditation coach. Keep it under 20 words.",
      }
    });
    return response.text || "Respire fundo e encontre a paz no agora.";
  } catch (error: any) {
    console.error("Gemini Error:", error);
    
    // Handle the "Requested entity was not found" error by potentially prompting for a key if applicable,
    // though for simple text tasks we usually just fallback to a default message.
    if (error?.message?.includes("Requested entity was not found")) {
      console.warn("Model not found or API key issue. Check model name or key permissions.");
    }
    
    return "Um momento de respiração muda todo o seu dia.";
  }
}
