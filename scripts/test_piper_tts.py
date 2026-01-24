#!/usr/bin/env python3
"""Test script for Piper TTS integration"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import asyncio
from python.helpers import piper_tts


async def main():
    print("=" * 50)
    print("PIPER TTS TEST")
    print("=" * 50)

    # Show available voices
    print(f"\nAvailable voices: {piper_tts.get_available_voices()}")

    # Test synthesis
    test_text = "Hallo! Dies ist ein Test der Piper Text-zu-Sprache Synthese."
    print(f"\nTest text: {test_text}")

    print("\nSynthesizing... (downloading model if needed)")
    try:
        audio_base64 = await piper_tts.synthesize_sentences([test_text])
        print(f"Success! Audio length: {len(audio_base64)} chars (base64)")

        # Save test audio
        import base64
        audio_bytes = base64.b64decode(audio_base64)
        output_path = os.path.join(os.path.dirname(__file__), "test_output.wav")
        with open(output_path, "wb") as f:
            f.write(audio_bytes)
        print(f"Saved to: {output_path}")

        # Try to play on macOS
        if sys.platform == "darwin":
            print("\nPlaying audio...")
            os.system(f"afplay {output_path}")

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    asyncio.run(main())
