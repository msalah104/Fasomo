#!/usr/bin/env python3
"""Synthesizes the bundled reminder tones.

The tones are built from plain sine waves here, so the app ships no
third-party audio. Run from the repository root:

    python3 tool/tones/generate_tones.py

It writes 44.1 kHz mono 16-bit WAVs into ios/Runner/ (iOS plays WAV
notification sounds from the app bundle) and, when ffmpeg with libvorbis is
on the PATH, Ogg Vorbis copies into android/app/src/main/res/raw/ (smaller
than WAV; Android plays both). Without ffmpeg the WAVs are copied to Android
instead.

The WAVs are deterministic: the same script always writes the same samples.
Android caches a channel's sound for good, so if a tone ever changes, bump
its channel id in
lib/core/services/notifications/notification_tone_channel.dart.
"""

import math
import shutil
import struct
import subprocess
import wave
from pathlib import Path

RATE = 44100
ROOT = Path(__file__).resolve().parents[2]
IOS_DIR = ROOT / "ios" / "Runner"
ANDROID_DIR = ROOT / "android" / "app" / "src" / "main" / "res" / "raw"


def silence(seconds):
    return [0.0] * int(seconds * RATE)


def add(buffer, start_seconds, samples, gain=1.0):
    """Mixes samples into buffer from start_seconds on."""
    offset = int(start_seconds * RATE)
    for i, value in enumerate(samples):
        if offset + i < len(buffer):
            buffer[offset + i] += value * gain


def struck(frequency, seconds, partials, decay, attack=0.004):
    """A struck tone: sine partials (ratio, amplitude, decay factor), each
    fading exponentially, with a short linear attack to avoid a click."""
    out = []
    for i in range(int(seconds * RATE)):
        t = i / RATE
        value = 0.0
        for ratio, amplitude, decay_factor in partials:
            envelope = math.exp(-t / (decay * decay_factor))
            value += amplitude * envelope * math.sin(
                2 * math.pi * frequency * ratio * t
            )
        if t < attack:
            value *= t / attack
        out.append(value)
    return out


def finish(buffer, peak, fade_in=0.005, fade_out=0.12):
    """Gentle fades at both ends, then normalizes the peak to `peak`."""
    n = len(buffer)
    fade_in_n = int(fade_in * RATE)
    fade_out_n = int(fade_out * RATE)
    for i in range(fade_in_n):
        buffer[i] *= i / fade_in_n
    for i in range(fade_out_n):
        # Raised-cosine tail, so the end is smooth rather than a ramp.
        buffer[n - 1 - i] *= 0.5 - 0.5 * math.cos(math.pi * i / fade_out_n)
    loudest = max(abs(v) for v in buffer) or 1.0
    return [v * peak / loudest for v in buffer]


def soft_chime():
    """Two notes a major sixth apart (E5 then C#6), like a doorbell chime."""
    partials = [(1.0, 1.0, 1.0), (2.0, 0.18, 0.5), (3.0, 0.05, 0.3)]
    buffer = silence(1.6)
    add(buffer, 0.0, struck(659.25, 1.6, partials, decay=0.45))
    add(buffer, 0.28, struck(1108.73, 1.32, partials, decay=0.40), gain=0.8)
    return finish(buffer, peak=0.70)


def bell():
    """A small bell on A4: inharmonic partials (hum, prime, tierce, quint,
    nominal and above), the higher ones dying away faster."""
    partials = [
        (0.5, 0.35, 1.6),
        (1.0, 1.0, 1.0),
        (1.19, 0.45, 0.8),
        (1.5, 0.30, 0.7),
        (2.0, 0.55, 0.55),
        (2.52, 0.20, 0.4),
        (3.01, 0.12, 0.3),
        (4.1, 0.06, 0.2),
    ]
    buffer = struck(440.0, 2.0, partials, decay=0.6, attack=0.002)
    return finish(buffer, peak=0.70, fade_out=0.25)


def gentle():
    """A soft rising G major arpeggio (G4, B4, D5) with slow attacks."""
    partials = [(1.0, 1.0, 1.0), (2.0, 0.08, 0.6)]
    buffer = silence(1.8)
    for start, frequency in ((0.0, 392.00), (0.22, 493.88), (0.44, 587.33)):
        note = struck(frequency, 1.8 - start, partials, decay=0.55, attack=0.04)
        add(buffer, start, note)
    return finish(buffer, peak=0.55, fade_in=0.02, fade_out=0.3)


def write_wav(path, samples):
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(
            b"".join(
                struct.pack("<h", max(-32767, min(32767, round(v * 32767))))
                for v in samples
            )
        )


def to_android(wav_path, name):
    if shutil.which("ffmpeg"):
        target = ANDROID_DIR / f"{name}.ogg"
        subprocess.run(
            [
                "ffmpeg", "-loglevel", "error", "-y", "-i", str(wav_path),
                "-c:a", "libvorbis", "-q:a", "5", "-map_metadata", "-1",
                "-fflags", "+bitexact", str(target),
            ],
            check=True,
        )
    else:
        target = ANDROID_DIR / f"{name}.wav"
        shutil.copyfile(wav_path, target)
    return target


def main():
    ANDROID_DIR.mkdir(parents=True, exist_ok=True)
    tones = {"tone_chime": soft_chime, "tone_bell": bell, "tone_gentle": gentle}
    for name, make in tones.items():
        wav_path = IOS_DIR / f"{name}.wav"
        write_wav(wav_path, make())
        android = to_android(wav_path, name)
        print(f"{wav_path.relative_to(ROOT)}  {android.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
