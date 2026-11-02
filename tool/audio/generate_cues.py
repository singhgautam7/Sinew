"""Synthesises Sinew's timer cue sounds. Pure stdlib, deterministic."""
import math, struct, sys, wave, os
RATE = 22050
def tone(freq, ms, vol=0.55):
    n = int(RATE * ms / 1000)
    out = []
    for i in range(n):
        t = i / RATE
        # 8 ms attack, exponential-ish release so it never clicks
        env = min(1.0, i / (RATE * 0.008)) * min(1.0, (n - i) / (RATE * 0.03))
        s = math.sin(2 * math.pi * freq * t) + 0.18 * math.sin(4 * math.pi * freq * t)
        out.append(vol * env * s / 1.18)
    return out
def silence(ms): return [0.0] * int(RATE * ms / 1000)
def write(path, samples):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 32767)) for s in samples))
out = sys.argv[1]
write(os.path.join(out, 'tick.wav'), tone(880, 110))                       # countdown 3, 2, 1
write(os.path.join(out, 'go.wav'), tone(1320, 380))                        # phase start: work
write(os.path.join(out, 'rest.wav'), tone(660, 320))                       # phase start: rest
write(os.path.join(out, 'warning.wav'), tone(990, 90) + silence(70) + tone(990, 90))  # 10 s warning
write(os.path.join(out, 'finish.wav'), tone(784, 140) + silence(40) + tone(988, 140) + silence(40) + tone(1319, 420))
