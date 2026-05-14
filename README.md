
# Neuro-Rehab Analyst Agent

This repository contains the real-time **Neuro-Rehab Analyst** agent built with Python, Firebase Firestore, and the Google Gemini AI SDK.

## Architecture & Workflow

The agent runs as a continuous background daemon or local service that uses a Firestore snapshot listener to monitor the `vr_session_logs` collection in real-time.

1. **Monitor**: Listens for document additions or updates in `vr_session_logs`.
2. **Filter**: Triggers logic only when a document's `status` field equals exactly `"Analysis Pending"`.
3. **Analyze & Reason**: Extracts the `raw_metrics` object/dictionary and sends it to the **Gemini 2.0 Flash** reasoning engine using your specified prompt to evaluate clinical hand tracking metrics and generate a customized, structured 3-step recovery plan.
4. **Update**: Automatically updates the Firestore document by:
   - Setting `status` to `"Completed"`
   - Adding the generated plan to the `ai_recommendation` field.

---

## Prerequisites

1. **Python 3.9+** installed (accessible via `python3` on macOS).
2. **Firebase Project** with Firestore enabled.
3. **Service Account Key**: Download your Firebase Admin SDK private key JSON file from the Firebase Console (`Project Settings > Service Accounts > Generate New Private Key`).
4. **Gemini API Key**: Get an API key from Google AI Studio.

---

## Installation & Setup

1. **Install dependencies**:
   Use `pip3` on macOS:
   ```bash
   pip3 install -r requirements.txt
   ```

2. **Set Environment Variables**:
   Configure your environment variables so the SDKs can authenticate autonomously:
   
   **On macOS / Linux:**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/firebase-service-account-key.json"
   export GEMINI_API_KEY="your_actual_gemini_api_key"
   ```

---

## Running the Agent

Start the agent monitoring service using `python3`:

```bash
python3 agent.py
```

### Expected Output Example

```text
[*] Firebase Admin SDK initialized successfully.
[*] Gemini AI Client initialized successfully.

[*] Listening in real-time to Firestore collection: 'vr_session_logs'...
[*] Waiting for documents with status: 'Analysis Pending'...

==================================================
[!] Triggered: Document 'session_001' has status 'Analysis Pending'.
[*] Raw metrics: {'left_hand_grip_strength': '40%', 'flexion_angle': '45deg', 'completion_time': '85s'}
[*] Sending data to Gemini 2.0 Flash...

[+] Generated Clinical Recovery Plan:
Step 1: Grip Activation - Perform light soft-ball squeezing exercises to gradually increase left hand grip strength above 40%.
Step 2: Flexion Extension - Practice passive wrist and finger extensions against a flat surface to improve the 45deg flexion angle.
Step 3: Task Coordination - Engage in short, targeted virtual reaching blocks to reduce overall completion time steadily.
--------------------------------------------------
[*] Updating Firestore document 'session_001'...
[+] Successfully updated status to 'Completed' and added ai_recommendation.
==================================================
```

---

## Alternative Deployment: Firebase Cloud Functions (Node.js)

If you prefer deploying this directly as a serverless Firebase trigger rather than running a background Python daemon, you can implement an equivalent event-driven trigger using Firebase Cloud Functions (2nd Gen) in TypeScript/JavaScript:

```javascript
const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");
const { GoogleGenAI } = require("@google/genai");

const db = getFirestore();
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

exports.neuroRehabAnalyst = onDocumentWritten("vr_session_logs/{sessionId}", async (event) => {
  const snapshot = event.data.after;
  if (!snapshot.exists) return;

  const data = snapshot.data();
  if (data.status !== "Analysis Pending") return;

  const rawMetrics = data.raw_metrics || {};
  
  const prompt = `Analyze this stroke patient's hand tracking data: ${JSON.stringify(rawMetrics)}. Provide a 3-step clinical recovery plan.`;

  const response = await ai.models.generateContent({
    model: 'gemini-2.0-flash',
    contents: prompt,
  });

  const plan = response.text;

  await snapshot.ref.update({
    status: "Completed",
    ai_recommendation: plan
  });
  
  console.log(`Successfully analyzed session ${event.params.sessionId}`);
});
```
