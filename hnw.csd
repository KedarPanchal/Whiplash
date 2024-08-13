<Cabbage>
  form caption("Whiplash") size(450, 590), guiMode("queue"), pluginId("def1")
  keyboard bounds(14, 450, 422, 95)
  ; ADSR Sliders
  rslider bounds(12, 14, 105, 101), channel("Attack"), range(0, 1, 0.01, 1, .01), text("Attack")
  rslider bounds(114, 14, 105, 101), channel("Decay"), range(0, 1, 0.5, 1, .01), text("Decay")
  rslider bounds(218, 14, 105, 101), channel("Sustain"), range(0, 1, 0.5, 1, .01), text("Sustain")
  rslider bounds(322, 14, 105, 101), channel("Release"), range(0, 1, 0.7, 1, .01), text("Release")

  ; Silly noise sliders (will give cooler names later)
  rslider bounds(12, 124, 105, 101), channel("Dirtiness"), range(0, 1, 0.5, 1, 0.01), text("Dirtiness") ; Adjusts low-pass filter of initial noise-generation filter equation
  rslider bounds(114, 124, 105, 101), channel("Wail"), range(0, 1, 0, 1, 0.01), text("Wail") ; Adjusts resonance of the noise when pitchshifting using a lowpass filter, allowing for a wail-tone to be created
  rslider bounds(218, 124, 105, 101), channel("Scratch"), range(0, 1, 0.5, 1, 0.01), text("Scratch") ; Adjusts the limit of the clipping filter to allow for clipping distortion. Inversely related to the clipping filter's limit
  rslider bounds(322, 124, 105, 101), channel("Depth"), range(-1, 1, 0, 1, 1), text("Depth") ; Adjusts how many octaves to transpost the noise's pitch up/down.
  
  ; More noise sliders + volume
  rslider bounds(12, 234, 105, 101), channel("Crunch"), range(0, 1, 0.5, 1, 0.01), text("Crunch") ; Adjusts the exponentiation of the noise signal
  rslider bounds(114, 234, 105, 101), channel("Suffocate"), range(0, 1, 0.5, 1, 0.01), text("Suffocate") ; Adjusts the phase distortion of the noise signal, adding more punch to lower noise and muting the higher noise frequencies
  rslider bounds(322, 234, 105, 101), channel("Volume"), range(0, 1, 0.8, 1, 0.01), text("Volume") ; Duh
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
      ; Set ADSR envelope
      iAttack chnget "Attack"
      iDecay chnget "Decay"
      iSustain chnget "Sustain"
      iRelease chnget "Release"
      kEnv madsr iAttack, iDecay, iSustain, iRelease

      ; Set parameter vars
      iFreq = p4
      iAmp = p5

      kbeta chnget "Dirtiness"
      kbeta = (kbeta * 2 - 1) * -1 ; Transpose kbeta range from 0-1 to -1-1 and invert it to make the dirtiness be the max value
      ; Make sure that my ears don't get blown out when at the limits
      if (kbeta == 1) then
        kbeta = 0.995
      elseif (kbeta == -1) then
        kbeta = -0.995
      endif
      
      kq chnget "Wail"
      kq = kq * 499 + 1 ; Transpose kq range from 0-1 to 1-500
      
      iLimit chnget "Scratch"
      iLimit = 1 - iLimit ; Invert to make the effect line up with the description
      ; Make sure my ears don't get blown out
      if (iLimit == 0) then
        iLimit = 0.001
      endif

      iTranspose chnget "Depth"
      iTranspose pow 2, iTranspose
      iFreq = iFreq * iTranspose
      
      kCrunch chnget "Crunch"
      kCrunch = (1 - kCrunch) * 2 ; Invert kCrunch and transpose range from 0-1 to 0-2
      ; Save my ears...again
      if (kCrunch == 0) then
        kCrunch = 0.001
      endif
      
      kSuffocate chnget "Suffocate"
      kSuffocate = (kSuffocate * 2 - 1) * -1 ; Transpose kSuffocate range from 0-1 to -1-1
      ; As with literally every *other* if statement, this is to save my ears when pushing a filter to the limits
      if (kSuffocate == -1) then
        kSuffocate = -0.999
      endif
      
      ; Generate noise
      aNoise noise iAmp, kbeta
      aFilteredNoise lowpass2 aNoise, iFreq, kq ; Apply a low pass filter for pitch modulation
      aFilteredNoise pdhalfy aFilteredNoise, kSuffocate
      aFilteredNoise powershape aFilteredNoise, kCrunch ; Exponentiates input signal to add distortion and scales accordingly 
      aFilteredNoise clip aFilteredNoise, 0, iLimit ; Apply a clipping distortion

      ; Spit out sound
      iVolume chnget "Volume"
      aOut gain aFilteredNoise, iVolume
      outs aOut*kEnv, aOut*kEnv
    endin
  </CsInstruments>
  <CsScore>
    ; Causes Csound to run for about 7000 years...
    f0 z
  </CsScore>
</CsoundSynthesizer>