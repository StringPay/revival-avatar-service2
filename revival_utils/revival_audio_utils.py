import librosa
import numpy as np
import wave

def add_silence_with_librosa(input_file: str, output_file: str, duration_sec: float = 2.5):
    """
    Adds silence to the end of a WAV file using librosa and numpy.

    Args:
        input_file: Path to the input WAV file.
        output_file: Path to save the modified WAV file.
        duration_sec: Duration of silence to add in seconds.
    """
    # 1. Load the audio file with Librosa
    # 'sr=None' ensures the original sample rate is preserved.
    audio, sr = librosa.load(input_file, sr=None)

    # 2. Create the silent segment with NumPy
    # Calculate the number of samples for the desired duration
    num_silent_samples = int(duration_sec * sr)
    
    # Create a silent array of zeros. Librosa loads as float, so we use np.float32
    silence = np.zeros(num_silent_samples, dtype=np.float32)

    # 3. Concatenate the original audio and the silence
    extended_audio = np.concatenate((audio, silence))

    # 4. Save the new audio using the built-in 'wave' module
    # Librosa audio is float, but WAV files expect integers (e.g., 16-bit).
    # We need to scale and convert it.
    audio_int = np.int16(extended_audio * 32767)

    with wave.open(output_file, 'w') as wf:
        wf.setnchannels(1)  # Assuming mono audio, librosa's default
        wf.setsampwidth(2)  # 2 bytes for 16-bit audio
        wf.setframerate(sr)
        wf.writeframes(audio_int.tobytes())

# --- Example Usage ---
# Add 3 seconds of silence
# add_silence_with_librosa("original_audio.wav", "audio_with_silence_librosa.wav", 3.0)

# print("Silence added successfully using Librosa!")

