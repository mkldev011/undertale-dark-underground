extends Node

# MusicGenerator.gd
# Procedural music generator for placeholder tracks
# Replace these with original compositions for the final game!

const SAMPLE_RATE = 44100
const BPM = 120

# Note frequencies (A4 = 440Hz)
var note_frequencies = {
	"C3": 130.81, "D3": 146.83, "E3": 164.81, "F3": 174.61, "G3": 196.00, "A3": 220.00, "B3": 246.94,
	"C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23, "G4": 392.00, "A4": 440.00, "B4": 493.88,
	"C5": 523.25, "D5": 587.33, "E5": 659.25, "F5": 698.46, "G5": 783.99, "A5": 880.00, "B5": 987.77,
	"C6": 1046.50
}

var beats_per_bar = 4
var beat_duration: float

func _ready() -> void:
	beat_duration = 60.0 / BPM

# Generate a sine wave note
func generate_sine_note(frequency: float, duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var num_samples = int(SAMPLE_RATE * duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)  # 16-bit samples
	
	var sample: float
	for i in range(num_samples):
		var time = float(i) / SAMPLE_RATE
		# Sine wave with envelope
		var envelope = 1.0
		var attack = duration * 0.1
		var release = duration * 0.3
		
		if time < attack:
			envelope = time / attack
		elif time > duration - release:
			envelope = (duration - time) / release
		
		sample = sin(2.0 * PI * frequency * time) * envelope * volume
		var int_sample = int(sample * 32767.0)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.data = data
	return stream

# Generate dark fantasy ambient loop
func generate_dark_fantasy_menu() -> AudioStreamWAV:
	var bar_duration = beat_duration * beats_per_bar
	var total_duration = bar_duration * 4  # 4 bars
	var num_samples = int(SAMPLE_RATE * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	# Dark ambient notes (low, mysterious)
	var notes = [
		{"freq": note_frequencies["C3"], "beat": 0},
		{"freq": note_frequencies["E3"], "beat": 1},
		{"freq": note_frequencies["G3"], "beat": 2},
		{"freq": note_frequencies["B3"], "beat": 3},
		{"freq": note_frequencies["C4"], "beat": 4},
		{"freq": note_frequencies["A3"], "beat": 5},
		{"freq": note_frequencies["F3"], "beat": 6},
		{"freq": note_frequencies["G3"], "beat": 7}
	]
	
	var sample: float
	for i in range(num_samples):
		var time = float(i) / SAMPLE_RATE
		var bar_time = fmod(time, bar_duration * 4)
		
		sample = 0.0
		for note in notes:
			var note_start = note["beat"] * beat_duration
			var note_duration = beat_duration * 0.9
			
			if bar_time >= note_start and bar_time < note_start + note_duration:
				var note_time = bar_time - note_start
				var envelope = 1.0
				
				# Slow attack and release for ambient feel
				var attack = note_duration * 0.3
				var release = note_duration * 0.5
				
				if note_time < attack:
					envelope = note_time / attack
				elif note_time > note_duration - release:
					envelope = (note_duration - note_time) / release
				
				sample += sin(2.0 * PI * note["freq"] * note_time) * envelope * 0.3
		
		# Add subtle low rumble
		sample += sin(2.0 * PI * 55 * time) * 0.1
		
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.loop = true
	stream.data = data
	return stream

# Generate simple battle theme
func generate_battle_theme() -> AudioStreamWAV:
	var bar_duration = beat_duration * beats_per_bar
	var total_duration = bar_duration * 4
	var num_samples = int(SAMPLE_RATE * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	# More intense notes
	var bass_pattern = [
		{"freq": note_frequencies["C3"], "beat": 0, "duration": 0.5},
		{"freq": note_frequencies["C3"], "beat": 0.5, "duration": 0.5},
		{"freq": note_frequencies["D3"], "beat": 1, "duration": 0.5},
		{"freq": note_frequencies["E3"], "beat": 1.5, "duration": 0.5},
		{"freq": note_frequencies["G3"], "beat": 2, "duration": 0.5},
		{"freq": note_frequencies["G3"], "beat": 2.5, "duration": 0.5},
		{"freq": note_frequencies["F3"], "beat": 3, "duration": 0.5},
		{"freq": note_frequencies["E3"], "beat": 3.5, "duration": 0.5}
	]
	
	var sample: float
	for i in range(num_samples):
		var time = float(i) / SAMPLE_RATE
		
		sample = 0.0
		for note in bass_pattern:
			var note_start = note["beat"] * beat_duration
			var note_duration = note["duration"] * beat_duration
			
			if time >= note_start and time < note_start + note_duration:
				var note_time = time - note_start
				var envelope = 1.0
				
				if note_time < 0.05:
					envelope = note_time / 0.05
				elif note_time > note_duration - 0.1:
					envelope = (note_duration - note_time) / 0.1
				
				sample += sin(2.0 * PI * note["freq"] * note_time) * envelope * 0.4
		
		# Add some harmonics
		sample += sin(2.0 * PI * 220 * time) * 0.1
		
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.loop = true
	stream.data = data
	return stream

# Generate ruins ambient theme
func generate_ruins_theme() -> AudioStreamWAV:
	var bar_duration = beat_duration * beats_per_bar
	var total_duration = bar_duration * 4
	var num_samples = int(SAMPLE_RATE * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	# Gentle, warm notes
	var melody = [
		{"freq": note_frequencies["E4"], "beat": 0},
		{"freq": note_frequencies["G4"], "beat": 1.5},
		{"freq": note_frequencies["A4"], "beat": 2},
		{"freq": note_frequencies["G4"], "beat": 3},
		{"freq": note_frequencies["E4"], "beat": 4},
		{"freq": note_frequencies["C4"], "beat": 5.5},
		{"freq": note_frequencies["D4"], "beat": 6},
		{"freq": note_frequencies["E4"], "beat": 7}
	]
	
	var sample: float
	for i in range(num_samples):
		var time = float(i) / SAMPLE_RATE
		var bar_time = fmod(time, bar_duration * 4)
		
		sample = 0.0
		for note in melody:
			var note_start = note["beat"] * beat_duration
			var note_duration = beat_duration * 1.2
			
			if bar_time >= note_start and bar_time < note_start + note_duration:
				var note_time = bar_time - note_start
				var envelope = 1.0
				
				var attack = note_duration * 0.2
				var release = note_duration * 0.6
				
				if note_time < attack:
					envelope = note_time / attack
				elif note_time > note_duration - release:
					envelope = (note_duration - note_time) / release
				
				sample += sin(2.0 * PI * note["freq"] * note_time) * envelope * 0.25
		
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.loop = true
	stream.data = data
	return stream

# Generate dark fountain theme
func generate_dark_fountain_theme() -> AudioStreamWAV:
	var bar_duration = beat_duration * beats_per_bar
	var total_duration = bar_duration * 4
	var num_samples = int(SAMPLE_RATE * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	# Eerie, ominous notes
	var notes = [
		{"freq": note_frequencies["C3"], "beat": 0},
		{"freq": note_frequencies["D3"], "beat": 2},
		{"freq": note_frequencies["C3"], "beat": 4},
		{"freq": note_frequencies["B2"], "beat": 6}
	]
	
	var sample: float
	for i in range(num_samples):
		var time = float(i) / SAMPLE_RATE
		var bar_time = fmod(time, bar_duration * 4)
		
		sample = 0.0
		
		# Base drone
		sample += sin(2.0 * PI * 65.41 * time) * 0.15  # C2
		sample += sin(2.0 * PI * 98.00 * time) * 0.1   # G2
		
		for note in notes:
			var note_start = note["beat"] * beat_duration
			var note_duration = beat_duration * 1.5
			
			if bar_time >= note_start and bar_time < note_start + note_duration:
				var note_time = bar_time - note_start
				var envelope = 1.0
				
				var release = note_duration * 0.7
				if note_time > note_duration - release:
					envelope = (note_duration - note_time) / release
				
				# Add slight detune for eerie effect
				sample += sin(2.0 * PI * note["freq"] * note_time) * envelope * 0.2
				sample += sin(2.0 * PI * (note["freq"] * 1.01) * note_time) * envelope * 0.1
		
		var int_sample = int(clamp(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = int_sample & 0xFF
		data[i * 2 + 1] = (int_sample >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.stereo = false
	stream.loop = true
	stream.data = data
	return stream

# Export generated music to files (call this once to generate placeholder music)
func export_all_music() -> void:
	print("Generating placeholder music files...")
	
	# Create music directory
	DirAccess.make_dir_recursive_absolute("res://audio/music")
	
	# Generate and save each track
	_save_wav("res://audio/music/dark_fantasy_menu.wav", generate_dark_fantasy_menu())
	print("Generated: dark_fantasy_menu.wav")
	
	_save_wav("res://audio/music/battle_theme.wav", generate_battle_theme())
	print("Generated: battle_theme.wav")
	
	_save_wav("res://audio/music/ruins_light.wav", generate_ruins_theme())
	print("Generated: ruins_light.wav")
	
	_save_wav("res://audio/music/dark_fountain.wav", generate_dark_fountain_theme())
	print("Generated: dark_fountain.wav")
	
	print("All placeholder music generated!")

func _save_wav(path: String, stream: AudioStreamWAV) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Simple WAV header
		var channels = 1 if not stream.stereo else 2
		var bits = 16
		var sample_rate = SAMPLE_RATE
		var data_size = stream.data.size()
		
		# RIFF header
		file.store_buffer("RIFF".to_utf8_buffer())
		file.store_32(36 + data_size)
		file.store_buffer("WAVE".to_utf8_buffer())
		
		# fmt chunk
		file.store_buffer("fmt ".to_utf8_buffer())
		file.store_32(16)  # chunk size
		file.store_16(1)   # PCM format
		file.store_16(channels)
		file.store_32(sample_rate)
		file.store_32(sample_rate * channels * bits / 8)  # byte rate
		file.store_16(channels * bits / 8)  # block align
		file.store_16(bits)
		
		# data chunk
		file.store_buffer("data".to_utf8_buffer())
		file.store_32(data_size)
		file.store_buffer(stream.data)
		
		file.close()
