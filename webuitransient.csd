<Cabbage>
;----------
; container    
;---------- 
 
form caption("Transient Detection Dev Board") size(800, 400), guiMode("queue"), colour(0,0,30) opcodeDir(".") logger("cabbagelogger.txt") Logger("cabbagelogger.txt") latency(883)
webview bounds(175, 12, 550, 150), channel("webview1"), mountPoint(".")   
button bounds(644, 168, 82, 28) channel("freeze"), text("freeze", "live"), corners(5), value(1) colour:0(115, 0, 39, 255) colour:1(203, 207, 0, 255)
button bounds(544, 168, 82, 28) channel("showWaveform"), text("waveform", "waveform"), corners(5), value(1) colour:0(115, 0, 39, 255) colour:1(203, 207, 0, 255)
button bounds(444, 168, 82, 28) channel("showEnveloppeDiff"), text("showEnveloppeDiff", "showEnveloppeDiff"), corners(5), value(1) colour:0(115, 0, 39, 255) colour:1(203, 207, 0, 255)
button bounds(344, 168, 82, 28) channel("showSlowEnveloppe"), text("showSlowEnveloppe", "showSlowEnveloppe"), corners(5), value(1) colour:0(115, 0, 39, 255) colour:1(203, 207, 0, 255)
button bounds(244, 168, 82, 28) channel("showFastEnveloppe"), text("showFastEnveloppe", "showFastEnveloppe"), corners(5), value(1) colour:0(115, 0, 39, 255) colour:1(203, 207, 0, 255)

;----------
; transients 
;---------- 

rslider  bounds(6, 12, 177, 161), channel("Sustain"),text("Left: Reduce sustain / Right: Reduce attack"), popupPostfix(" %") range(-100, 100, 100, 1, 0.1),  $MarkerBig _info("reduce/boost sustain") colour(253, 252, 220, 255) fontColour(214, 119, 119, 255) markerColour(240, 113, 103, 255) markerStart(0) outlineColour(240, 113, 103, 255) textColour(240, 113, 103, 255) trackerColour(240, 113, 103, 255) valueTextBox(1) 
rslider bounds(82, 242, 129, 86), channel("FastAttack") text("FastAttack") range(0, 1, 0.001, 1, 0.001), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255) valueTextBox(1)
rslider bounds(218, 242, 118, 85), channel("FastRelease") text("FastRelease") range(0, 1, 0.025, 1, 0.001), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255) valueTextBox(1)
rslider bounds(344, 242, 113, 86), channel("SlowRelease") text("SlowRelease") range(0, 1, 0.075, 1, 0.001), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255) valueTextBox(1)
rslider bounds(466, 242, 112, 85), channel("SlowAttack") text("SlowAttack") range(0, 1, 0.001, 1, 0.001), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255) valueTextBox(1)
; misc  
rslider bounds(724, 324, 62, 64), channel("DryWet") text("Dry/Wet") range(0, 1, 1, 1, 0.01), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255)
rslider bounds(644, 324, 68, 65), channel("Gain") text("Gain") range(0, 1, 0, 1, 0.01), $MarkerSecond colour(253, 252, 220, 255) fontColour(0, 129, 167, 255) markerColour(0, 129, 167, 255) markerStart(0) outlineColour(0, 129, 167, 255) textColour(0, 129, 167, 255) trackerColour(0, 129, 167, 255)
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d --displays
</CsOptions>

<CsInstruments>
;===================================
; Orchestra Header
;===================================
; sr is set by host
ksmps = 64
nchnls = 2
0dbfs = 1

;===================================
; Global Variables
;===================================
gkcurrentval = 0
gkcurrentvalwaveform = 0
gknbvals = 0
gknbvalsenv = 0
gilen = 131072
gicps = sr/gilen

;===================================
; User-Defined Opcodes
;===================================
opcode transient_detection, aaa, akkkk
    ain, kfastrelease, kslowrelease, kfastattack, kslowattack xin
    
    kslowreleasesensi = 1
    kpowsensi = 1

    ; Envelope following
    afastrelease follow2 ain, kfastattack, kfastrelease
    aslowrelease follow2 ain, kslowattack, kslowrelease
    
    kslowreleaseadj = kslowrelease
    kfastreleaseadj = kfastrelease

    ; Multiple passes of envelope following for smoother results
    afastrelease follow2 afastrelease, kfastattack, kfastreleaseadj
    aslowrelease follow2 aslowrelease, kslowattack, kslowreleaseadj
    afastrelease follow2 afastrelease, kfastattack, kfastreleaseadj
    aslowrelease follow2 aslowrelease, kslowattack, kslowreleaseadj
    afastrelease follow2 afastrelease, kfastattack, kfastreleaseadj
    aslowrelease follow2 aslowrelease, kslowattack, kslowreleaseadj
    afastrelease follow2 afastrelease, kfastattack, kfastreleaseadj
    aslowrelease follow2 aslowrelease, kslowattack, kslowreleaseadj

    ; Convert to control rate
    kfastrelease downsamp afastrelease
    kslowrelease downsamp aslowrelease

    ; Ensure slow release never goes below fast release
    kslowrelease = (kfastrelease >= kslowrelease ? kfastrelease : kslowrelease)

    ; Convert back to audio rate
    afastrelease upsamp kfastrelease
    aslowrelease upsamp kslowrelease

    ; Normalize and calculate sustain difference
    afastrelease = afastrelease/0dbfs
    aslowrelease = aslowrelease/0dbfs
    asustaindiff divz afastrelease, aslowrelease, 0

    ; Smooth the result
    asustaindiff tone asustaindiff, 1000

    xout asustaindiff, afastrelease, aslowrelease
endop

opcode recordAndSend, 0, aiS
    aSig, iTable, Scallback xin
    kCnt init 0
    kSig downsamp aSig
    setksmps 16
    tabw kSig, kCnt, iTable
    kCnt = (kCnt < ftlen(iTable)-1 ? kCnt + 1 : 0)
    
    kFreeze cabbageGetValue "freeze"
    
    if (kCnt == ftlen(iTable)-1) && (kFreeze == 1) then
        cabbageWebSendTable k(1), "webview1", Scallback, iTable
    endif
endop

;===================================
; Instruments
;===================================
instr 1
    ; Initialize mode settings
    kdemo = 0
    ktransientsonly = 0
    iport = 0.01

    ; Get UI control values
    kgain chnget "Gain"
    kgain port kgain, iport
    
    ksustaingain chnget "Sustain"
    ksustaingain port ksustaingain, iport
    katkgain chnget "Attack"
    katkgain port katkgain, iport

    kfastrelease chnget "FastRelease"
    kfastrelease port kfastrelease, iport
    kslowrelease chnget "SlowRelease"
    kslowrelease port kslowrelease, iport
    kfastattack chnget "FastAttack"
    kfastattack port kfastattack, iport
    kslowattack chnget "SlowAttack"
    kslowattack port kslowattack, iport

    ; Get display settings
    kShowWaveform cabbageGetValue "showWaveform"
    kShowEnveloppeDiff cabbageGetValue "showEnveloppeDiff"
    kShowEnveloppeFast cabbageGetValue "showFastEnveloppe"
    kShowEnveloppeSlow cabbageGetValue "showSlowEnveloppe"

    kmix chnget "DryWet"
    kmix port kmix, iport

    ; Audio input
    a1, a2 diskin2 "cj drum loop - 85BPM.wav", 1, 0, 1

    ; Process transients
    asustaindiff, asustainfast, asustainslow transient_detection a1, kfastrelease, kslowrelease, kfastattack, kslowattack
    asustaindiff = 1-asustaindiff
    asustaindiff tone asustaindiff, 1000
    
    a1 delay a1, 0.02
    a1w = a1

    ; Process sustain gain
    ksustaingain = ksustaingain/100
    if ksustaingain < -0.001 then
        aEnv1 = asustaindiff
    endif
    if ksustaingain > 0.001 then
        aEnv1 = 1-asustaindiff
    endif

    ; Send data to UI
    recordAndSend a1w*a(kShowWaveform), 1, "webUIDrawScrollingWaveform"
    recordAndSend aEnv1*a(kShowEnveloppeDiff), 2, "webUIDrawScrollingWaveformEnv"
    recordAndSend asustainfast*a(kShowEnveloppeFast), 3, "webUIDrawScrollingWaveformEnvFast"
    recordAndSend asustainslow*a(kShowEnveloppeSlow), 4, "webUIDrawScrollingWaveformEnvSlow"

    ; Mix and output
    a1w ntrpol a1w, a1w*aEnv1, abs(ksustaingain)
    a1w ntrpol a1, a1w, kmix
    
    outs kgain*a1w, kgain*a1w
endin
</CsInstruments>

<CsScore>
;===================================
; Score
;===================================
f1 0 2048 7 0 2048 0
f2 0 2048 7 0 2048 0
f3 0 2048 7 0 2048 0
f4 0 2048 7 0 2048 0
i 1 0 [60 * 60 * 24 * 7]
</CsScore>

</CsoundSynthesizer>