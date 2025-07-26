#!/usr/bin/env python3
"""
Audio Generator untuk Flutter Board Game Adventure
Membuat audio assets sederhana menggunakan synthesized sounds
"""

import os
import math
import wave
import struct

def generate_sine_wave(frequency, duration, sample_rate=44100, amplitude=0.5):
    """Generate sine wave untuk tone sederhana"""
    frames = int(duration * sample_rate)
    wave_data = []
    
    for i in range(frames):
        # Generate sine wave
        value = amplitude * math.sin(2 * math.pi * frequency * i / sample_rate)
        # Apply envelope (fade in/out)
        envelope = 1.0
        if i < sample_rate * 0.01:  # Fade in
            envelope = i / (sample_rate * 0.01)
        elif i > frames - sample_rate * 0.01:  # Fade out
            envelope = (frames - i) / (sample_rate * 0.01)
        
        value *= envelope
        wave_data.append(int(value * 32767))
    
    return wave_data

def generate_noise(duration, sample_rate=44100, amplitude=0.3):
    """Generate white noise untuk sound effects"""
    import random
    frames = int(duration * sample_rate)
    wave_data = []
    
    for i in range(frames):
        # Generate random noise
        value = amplitude * (random.random() * 2 - 1)
        # Apply envelope
        envelope = 1.0
        if i < sample_rate * 0.005:  # Quick fade in
            envelope = i / (sample_rate * 0.005)
        elif i > frames - sample_rate * 0.05:  # Fade out
            envelope = (frames - i) / (sample_rate * 0.05)
        
        value *= envelope
        wave_data.append(int(value * 32767))
    
    return wave_data

def generate_chord(frequencies, duration, sample_rate=44100, amplitude=0.3):
    """Generate chord dari multiple frequencies"""
    frames = int(duration * sample_rate)
    wave_data = []
    
    for i in range(frames):
        value = 0
        for freq in frequencies:
            value += amplitude * math.sin(2 * math.pi * freq * i / sample_rate)
        
        value /= len(frequencies)  # Normalize
        
        # Apply envelope
        envelope = 1.0
        if i < sample_rate * 0.01:
            envelope = i / (sample_rate * 0.01)
        elif i > frames - sample_rate * 0.1:
            envelope = (frames - i) / (sample_rate * 0.1)
        
        value *= envelope
        wave_data.append(int(value * 32767))
    
    return wave_data

def save_wav(wave_data, filename, sample_rate=44100):
    """Save wave data ke file WAV"""
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        
        # Convert to bytes
        wav_data = struct.pack('<' + 'h' * len(wave_data), *wave_data)
        wav_file.writeframes(wav_data)
    
    print(f"Created: {filename}")

def generate_8bit_melody(notes, note_duration=0.3, sample_rate=44100):
    """Generate 8-bit style melody"""
    # Note frequencies (C4 scale)
    note_freq = {
        'C': 261.63, 'D': 293.66, 'E': 329.63, 'F': 349.23,
        'G': 392.00, 'A': 440.00, 'B': 493.88, 'C5': 523.25,
        'REST': 0
    }
    
    wave_data = []
    for note in notes:
        if note == 'REST':
            # Silence
            frames = int(note_duration * sample_rate)
            wave_data.extend([0] * frames)
        else:
            freq = note_freq.get(note, 440)
            note_data = generate_sine_wave(freq, note_duration, sample_rate, 0.4)
            wave_data.extend(note_data)
    
    return wave_data

def main():
    """Generate semua audio assets"""
    print("Generating audio assets...")
    
    # Buat direktori audio
    os.makedirs('flutter_board_game/assets/audio', exist_ok=True)
    
    # 1. Background Music - Menu Theme (8-bit style)
    print("Generating background music...")
    menu_melody = ['C', 'E', 'G', 'C5', 'G', 'E', 'C', 'REST']
    menu_music = generate_8bit_melody(menu_melody, 0.5)
    save_wav(menu_music, 'flutter_board_game/assets/audio/menu_theme.wav')
    
    # 2. Gameplay Theme
    gameplay_melody = ['G', 'A', 'B', 'C5', 'B', 'A', 'G', 'F', 'E', 'D', 'C', 'REST']
    gameplay_music = generate_8bit_melody(gameplay_melody, 0.4)
    save_wav(gameplay_music, 'flutter_board_game/assets/audio/gameplay_theme.wav')
    
    # 3. Victory Theme
    victory_melody = ['C', 'E', 'G', 'C5', 'C5', 'G', 'E', 'C']
    victory_music = generate_8bit_melody(victory_melody, 0.3)
    save_wav(victory_music, 'flutter_board_game/assets/audio/victory_theme.wav')
    
    # 4. Sound Effects
    print("Generating sound effects...")
    
    # Seed plant sound (high pitch beep)
    seed_sound = generate_sine_wave(800, 0.2, amplitude=0.4)
    save_wav(seed_sound, 'flutter_board_game/assets/audio/seed_plant.wav')
    
    # Energy gain sound (ascending chord)
    energy_sound = generate_chord([400, 500, 600], 0.3)
    save_wav(energy_sound, 'flutter_board_game/assets/audio/energy_gain.wav')
    
    # Energy full sound (triumphant chord)
    energy_full = generate_chord([523, 659, 784], 0.5)
    save_wav(energy_full, 'flutter_board_game/assets/audio/energy_full.wav')
    
    # Dice roll sound (rattling noise)
    dice_roll = generate_noise(0.8, amplitude=0.2)
    save_wav(dice_roll, 'flutter_board_game/assets/audio/dice_roll.wav')
    
    # Dice land sound (thud)
    dice_land = generate_sine_wave(150, 0.1, amplitude=0.6)
    save_wav(dice_land, 'flutter_board_game/assets/audio/dice_land.wav')
    
    # Footstep sounds
    footstep1 = generate_sine_wave(200, 0.1, amplitude=0.3)
    save_wav(footstep1, 'flutter_board_game/assets/audio/footstep_1.wav')
    
    footstep2 = generate_sine_wave(180, 0.1, amplitude=0.3)
    save_wav(footstep2, 'flutter_board_game/assets/audio/footstep_2.wav')
    
    # Tile effects
    # Normal tile (soft beep)
    tile_normal = generate_sine_wave(300, 0.15, amplitude=0.2)
    save_wav(tile_normal, 'flutter_board_game/assets/audio/tile_normal.wav')
    
    # Obstacle sound (harsh noise)
    obstacle_sound = generate_noise(0.3, amplitude=0.4)
    save_wav(obstacle_sound, 'flutter_board_game/assets/audio/tile_obstacle.wav')
    
    # Bonus sound (happy chord)
    bonus_sound = generate_chord([523, 659, 784, 988], 0.4)
    save_wav(bonus_sound, 'flutter_board_game/assets/audio/tile_bonus.wav')
    
    # Branch sound (questioning tone)
    branch_sound = generate_sine_wave(400, 0.2, amplitude=0.3)
    branch_data = generate_sine_wave(500, 0.2, amplitude=0.3)
    branch_sound.extend(branch_data)
    save_wav(branch_sound, 'flutter_board_game/assets/audio/tile_branch.wav')
    
    # Finish sound (victory fanfare)
    finish_melody = ['C', 'E', 'G', 'C5']
    finish_sound = generate_8bit_melody(finish_melody, 0.25)
    save_wav(finish_sound, 'flutter_board_game/assets/audio/tile_finish.wav')
    
    # UI Sounds
    print("Generating UI sounds...")
    
    # Button hover (soft beep)
    button_hover = generate_sine_wave(600, 0.05, amplitude=0.2)
    save_wav(button_hover, 'flutter_board_game/assets/audio/button_hover.wav')
    
    # Button click (click sound)
    button_click = generate_sine_wave(800, 0.08, amplitude=0.4)
    save_wav(button_click, 'flutter_board_game/assets/audio/button_click.wav')
    
    # Menu select (confirmation beep)
    menu_select = generate_chord([400, 600], 0.15)
    save_wav(menu_select, 'flutter_board_game/assets/audio/menu_select.wav')
    
    # Notification (attention sound)
    notification = generate_sine_wave(1000, 0.1, amplitude=0.3)
    notification.extend(generate_sine_wave(800, 0.1, amplitude=0.3))
    save_wav(notification, 'flutter_board_game/assets/audio/notification.wav')
    
    print("\n✅ Audio generation completed!")
    print("Generated audio files:")
    print("- 3 background music tracks")
    print("- 12 sound effects")
    print("- 4 UI sounds")
    print("\nTotal: 19 audio files")

if __name__ == "__main__":
    main()
