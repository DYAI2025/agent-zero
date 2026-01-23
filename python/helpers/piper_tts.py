# piper_tts.py
# Alternative TTS engine using Piper (CPU-based, low latency)
# Supports German and 20+ other languages

import base64
import io
import os
import asyncio
import wave
from pathlib import Path

# Optional imports for Agent Zero integration (graceful fallback for standalone use)
try:
    from python.helpers.print_style import PrintStyle
    from python.helpers.notification import NotificationManager, NotificationType, NotificationPriority
    _HAS_NOTIFICATIONS = True
except ImportError:
    _HAS_NOTIFICATIONS = False
    class PrintStyle:
        @staticmethod
        def standard(msg): print(msg)
        @staticmethod
        def error(msg): print(f"ERROR: {msg}")

_voice = None
_model_path = None
_config_path = None
is_updating_model = False

# Default model paths
MODELS_DIR = Path(__file__).parent.parent.parent / "models" / "piper"
DEFAULT_MODEL = "de_DE-thorsten-high"

# Available voices (can be extended)
AVAILABLE_VOICES = {
    "de_DE-thorsten-high": {
        "url_model": "https://huggingface.co/rhasspy/piper-voices/resolve/main/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx",
        "url_config": "https://huggingface.co/rhasspy/piper-voices/resolve/main/de/de_DE/thorsten/high/de_DE-thorsten-high.onnx.json",
        "sample_rate": 22050,
        "language": "de"
    },
    "en_US-lessac-high": {
        "url_model": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx",
        "url_config": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/high/en_US-lessac-high.onnx.json",
        "sample_rate": 22050,
        "language": "en"
    },
    "en_GB-alan-medium": {
        "url_model": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alan/medium/en_GB-alan-medium.onnx",
        "url_config": "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alan/medium/en_GB-alan-medium.onnx.json",
        "sample_rate": 22050,
        "language": "en"
    }
}


async def download_model(voice_name: str = DEFAULT_MODEL):
    """Download voice model if not present"""
    global is_updating_model

    if voice_name not in AVAILABLE_VOICES:
        raise ValueError(f"Unknown voice: {voice_name}. Available: {list(AVAILABLE_VOICES.keys())}")

    voice_info = AVAILABLE_VOICES[voice_name]
    model_path = MODELS_DIR / f"{voice_name}.onnx"
    config_path = MODELS_DIR / f"{voice_name}.onnx.json"

    # Create models directory if needed
    MODELS_DIR.mkdir(parents=True, exist_ok=True)

    if model_path.exists() and config_path.exists():
        return model_path, config_path

    is_updating_model = True
    try:
        import urllib.request

        if _HAS_NOTIFICATIONS:
            NotificationManager.send_notification(
                NotificationType.INFO,
                NotificationPriority.NORMAL,
                f"Downloading Piper voice: {voice_name}...",
                display_time=99,
                group="piper-download"
            )
        PrintStyle.standard(f"Downloading Piper voice model: {voice_name}...")

        # Download model
        if not model_path.exists():
            urllib.request.urlretrieve(voice_info["url_model"], model_path)
            PrintStyle.standard(f"Downloaded: {model_path.name}")

        # Download config
        if not config_path.exists():
            urllib.request.urlretrieve(voice_info["url_config"], config_path)
            PrintStyle.standard(f"Downloaded: {config_path.name}")

        if _HAS_NOTIFICATIONS:
            NotificationManager.send_notification(
                NotificationType.INFO,
                NotificationPriority.NORMAL,
                f"Piper voice {voice_name} ready.",
                display_time=2,
                group="piper-download"
            )

        return model_path, config_path

    finally:
        is_updating_model = False


async def preload(voice_name: str = DEFAULT_MODEL):
    """Preload Piper TTS model"""
    global _voice, _model_path, _config_path, is_updating_model

    while is_updating_model:
        await asyncio.sleep(0.1)

    try:
        is_updating_model = True

        if _voice is None:
            if _HAS_NOTIFICATIONS:
                NotificationManager.send_notification(
                    NotificationType.INFO,
                    NotificationPriority.NORMAL,
                    "Loading Piper TTS model...",
                    display_time=99,
                    group="piper-preload"
                )
            PrintStyle.standard("Loading Piper TTS model...")

            # Download model if needed
            _model_path, _config_path = await download_model(voice_name)

            # Load Piper voice
            from piper import PiperVoice
            _voice = PiperVoice.load(str(_model_path), config_path=str(_config_path))

            if _HAS_NOTIFICATIONS:
                NotificationManager.send_notification(
                    NotificationType.INFO,
                    NotificationPriority.NORMAL,
                    "Piper TTS model loaded.",
                    display_time=2,
                    group="piper-preload"
                )
            PrintStyle.standard("Piper TTS model loaded.")

    finally:
        is_updating_model = False


def _is_downloading():
    return is_updating_model


async def is_downloading():
    return _is_downloading()


def _is_downloaded():
    return _voice is not None


async def is_downloaded():
    return _is_downloaded()


async def synthesize_sentences(sentences: list[str], voice_name: str = DEFAULT_MODEL):
    """Generate audio for multiple sentences and return concatenated base64 audio"""
    await preload(voice_name)

    if _voice is None:
        raise RuntimeError("Piper TTS model not loaded")

    try:
        # Combine all sentences
        full_text = " ".join(s.strip() for s in sentences if s.strip())

        if not full_text:
            return ""

        # Create WAV file in memory
        wav_buffer = io.BytesIO()
        with wave.open(wav_buffer, 'wb') as wav_file:
            _voice.synthesize_wav(full_text, wav_file)

        # Return base64 encoded audio
        wav_buffer.seek(0)
        return base64.b64encode(wav_buffer.read()).decode("utf-8")

    except Exception as e:
        PrintStyle.error(f"Error in Piper TTS synthesis: {e}")
        raise


async def synthesize_text(text: str, voice_name: str = DEFAULT_MODEL) -> bytes:
    """Synthesize text to raw WAV bytes (for streaming)"""
    await preload(voice_name)

    if _voice is None:
        raise RuntimeError("Piper TTS model not loaded")

    wav_buffer = io.BytesIO()
    with wave.open(wav_buffer, 'wb') as wav_file:
        _voice.synthesize_wav(text, wav_file)

    wav_buffer.seek(0)
    return wav_buffer.read()


def get_available_voices() -> list[str]:
    """Return list of available voice names"""
    return list(AVAILABLE_VOICES.keys())


def get_voice_info(voice_name: str) -> dict:
    """Return info about a specific voice"""
    if voice_name not in AVAILABLE_VOICES:
        raise ValueError(f"Unknown voice: {voice_name}")
    return AVAILABLE_VOICES[voice_name]
