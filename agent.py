import os
import time
import firebase_admin
from firebase_admin import credentials, firestore
from google import genai
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# Initialize Firebase Admin SDK
# Autodetects standard GOOGLE_APPLICATION_CREDENTIALS or Firebase default credentials
try:
    firebase_admin.initialize_app()
    print("[*] Firebase Admin SDK initialized successfully.")
except ValueError:
    # Fallback if app already initialized
    pass
except Exception as e:
    print(f"[!] Warning during Firebase initialization: {e}")

# Initialize Firestore client
try:
    db = firestore.client()
except Exception as e:
    print(f"[!] Could not initialize Firestore client: {e}")
    db = None

# Initialize Gemini Client using google-genai SDK
# Automatically utilizes the GEMINI_API_KEY environment variable
try:
    ai_client = genai.Client()
    print("[*] Gemini AI Client initialized successfully.")
except Exception as e:
    print(f"[!] Could not initialize Gemini Client: {e}")
    ai_client = None


def generate_physiotherapy_plan(raw_metrics) -> str:
    """
    Sends hand tracking data to Gemini 2.0 Flash to generate a 3-step clinical recovery plan.
    """
    if not ai_client:
        return "Error: Gemini AI Client is not initialized."

    # Prompting Gemini exactly as requested
    prompt = f"Analyze this stroke patient's hand tracking data: {raw_metrics}. Provide a 3-step clinical recovery plan."
    
    try:
        # Using Gemini 2.0 Flash exactly as specified
        response = ai_client.models.generate_content(
            model='gemini-2.0-flash',
            contents=prompt
        )
        return response.text.strip()
    except Exception as e:
        print(f"[-] Error generating plan with Gemini: {e}")
        return f"Error generating plan: {str(e)}"


def on_snapshot(col_snapshot, changes, read_time):
    """Callback triggered on real-time collection updates."""
    for change in changes:
        if change.type.name in ['ADDED', 'MODIFIED']:
            doc = change.document
            data = doc.to_dict() or {}

            # Process when status is exactly 'Analysis Pending'
            if data.get('status') == 'Analysis Pending':
                print(f"\n==================================================")
                print(f"[!] Triggered: Document '{doc.id}' has status 'Analysis Pending'.")
                
                raw_metrics = data.get('raw_metrics', {})
                print(f"[*] Raw metrics: {raw_metrics}")

                print("[*] Sending data to Gemini 2.0 Flash...")
                plan = generate_physiotherapy_plan(raw_metrics)

                print("\n[+] Generated Clinical Recovery Plan:")
                print(plan)
                print("--------------------------------------------------")

                print(f"[*] Updating Firestore document '{doc.id}'...")
                try:
                    doc.reference.update({
                        'status': 'Completed',
                        'ai_recommendation': plan
                    })
                    print(f"[+] Successfully updated status to 'Completed' and added ai_recommendation.")
                except Exception as e:
                    print(f"[-] Failed to update document '{doc.id}': {e}")
                print(f"==================================================\n")


def main():
    if not db:
        print("[!] Exiting script: Firestore client unavailable.")
        return

    collection_name = 'vr_session_logs'
    print(f"\n[*] Listening in real-time to Firestore collection: '{collection_name}'...")
    print("[*] Waiting for documents with status: 'Analysis Pending'...\n")

    collection_ref = db.collection(collection_name)
    
    # Attach real-time Firestore listener
    doc_watch = collection_ref.on_snapshot(on_snapshot)

    # Keep the main thread running to listen for events
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[*] Stopping real-time listener.")


if __name__ == '__main__':
    main()
