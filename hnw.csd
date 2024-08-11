<Cabbage>
form caption("HNW") size(450, 480), guiMode("queue"), pluginId("def1")
keyboard bounds(14, 340, 422, 95)
; ADSR Sliders
rslider bounds(12, 14, 105, 101), channel("attack"), range(0, 1, 0.01, 1, .01), text("Attack")
rslider bounds(114, 14, 105, 101), channel("decay"), range(0, 1, 0.5, 1, .01), text("Decay")
rslider bounds(218, 14, 105, 101), channel("sustain"), range(0, 1, 0.5, 1, .01), text("Sustain")
rslider bounds(322, 14, 105, 101), channel("release"), range(0, 1, 0.7, 1, .01), text("Release")

; Silly noise sliders (will give cooler names later)
rslider bounds(12, 124, 105, 101), channel("kbeta"), range(-1, 1, 0, 1, 0.01), text("Low Pass")
rslider bounds(114, 124, 105, 101), channel("resonance"), range(1, 500, 1, 0.1), text("Resonance")
rslider bounds(218, 124, 105, 101), channel("limit"), range(0, 1, 0.5, 1, 0.01), text("Clipping")
rslider bounds(322, 124, 105, 101), channel("transpose"), range(-1, 1, 0, 1, 1), text("Transpose")
rslider bounds(322, 234, 105, 101), channel("volume"), range(0, 1, 0.8, 1, 0.01), text("Gain")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
; Initialize the global variables.
sr = 44100 
ksmps = 32
nchnls = 3
0dbfs = 1

; Instrument will be triggered by keyboard widget
instr 1
; Set constants
iFreq = p4
iAmp = p5

; Set ADSR envelope
iAttack chnget "attack"
iDecay chnget "decay"
iSustain chnget "sustain"
iRelease chnget "release"
kEnv madsr iAttack, iDecay, iSustain, iRelease

; Generate noise
kbeta chnget "kbeta"
kq chnget "resonance"
iLimit chnget "limit"
a

aNoise noise iAmp, kbeta
aFilteredNoise lowpass2 aNoise, iFreq, kq ; Apply a low pass filter for pitch modulation
aFilteredNoise clip aFilteredNoise, 0, iLimit ; Apply a clipping distortion

; Spit out sound
iVolume chnget "volume"
aOut gain aFilteredNoise, iVolume
outs aOut*kEnv, aOut*kEnv
endin

</CsInstruments>
<CsScore>
; Causes Csound to run for about 7000 years...
f0 z
</CsScore>
</CsoundSynthesizer>
