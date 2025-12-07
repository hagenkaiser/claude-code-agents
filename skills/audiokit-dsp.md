# AudioKit 5 DSP Expert Skill

You are an expert in audio DSP programming using AudioKit 5 for iOS/macOS. This skill provides comprehensive knowledge for building AUv3-compatible samplers, synthesizers, and MIDI sequencers.

## CRITICAL RULES

1. **AudioKit 5 ONLY** - Never use AudioKit 4 patterns. Use main branch dependencies.
2. **AUv3 First** - All new projects should be AUv3-compatible from the start
3. **Use existing AudioKit nodes** when available before implementing custom DSP
4. **Real-time thread safety** - Never allocate, lock, or block in render callbacks

## AudioKit 5 Ecosystem

### Package Dependencies (Package.swift)

```swift
dependencies: [
    // Core AudioKit - ALWAYS use main branch
    .package(url: "https://github.com/AudioKit/AudioKit.git", branch: "main"),

    // Extended DSP operations (for advanced synthesis)
    .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", branch: "main"),

    // Operations framework (for complex DSP chains)
    .package(url: "https://github.com/AudioKit/SporthAudioKit.git", branch: "main"),

    // Advanced synthesizers (optional)
    .package(url: "https://github.com/AudioKit/DunneAudioKit.git", branch: "main"),

    // SwiftUI keyboard component
    .package(url: "https://github.com/AudioKit/Keyboard.git", branch: "main"),

    // Music theory (Pitch, Note)
    .package(url: "https://github.com/AudioKit/Tonic.git", from: "1.0.7"),
]
```

### What's in Each Package

**AudioKit (Core)**:
- `AudioEngine` - Main audio processing engine
- `MIDISampler` - EXS24, SF2, WAV playback
- `Reverb`, `Delay` - Basic effects
- `Oscillator` - Basic waveform generation
- `MIDI` + `MIDIListener` - MIDI handling
- `Settings` - Global configuration

**SoundpipeAudioKit** (Advanced DSP Nodes):
- Advanced oscillators: `DynamicOscillator`, `FMOscillator`, `MorphingOscillator`, `PWMOscillator`
- Analog-modeled filters: `MoogLadder`, `Korg35Filter`, `RolandTB303Filter`
- Envelopes: `AmplitudeEnvelope`
- Modulation: `Tremolo`, `Vibrato`, `AutoPan`
- Physical modeling: `PluckedString`, `Clarinet`, `Flute`
- Analysis: `PitchTap`, `AmplitudeTap`, `FFTTap`

**SporthAudioKit** (Operations Framework):
- `Operation` - Chainable DSP building blocks
- `OperationGenerator` - Create custom generators from operations
- `OperationEffect` - Create custom effects from operations
- Complex interconnected DSP graphs with up to 14 parameters

---

## SporthAudioKit Operations Framework

Operations allow you to build complex, interconnected DSP using a functional approach. Operations compile to Sporth (a stack-based DSP language) and run efficiently.

### Creating an OperationGenerator

```swift
import SporthAudioKit

// Simple sine oscillator generator
let generator = OperationGenerator { parameters in
    let frequency = parameters[0]  // parameter1
    let amplitude = parameters[1]  // parameter2
    return Operation.sineWave(frequency: frequency, amplitude: amplitude)
}

// Set parameter ranges
generator.parameter1 = 440   // frequency
generator.parameter2 = 0.5   // amplitude

// Connect to engine
engine.output = generator
generator.start()
```

### Creating an OperationEffect

```swift
import SporthAudioKit

// Apply filter effect to input
let effect = OperationEffect(inputNode) { input, parameters in
    let cutoff = parameters[0]
    let resonance = parameters[1]
    return input.moogLadderFilter(
        cutoffFrequency: cutoff,
        resonance: resonance
    )
}

effect.parameter1 = 1000  // cutoff
effect.parameter2 = 0.5   // resonance

engine.output = effect
```

### Stereo Operations

```swift
// Stereo generator with left/right channels
let stereoGen = OperationGenerator(channelCount: 2) { parameters in
    let freq = parameters[0]
    let left = Operation.sineWave(frequency: freq)
    let right = Operation.sineWave(frequency: freq * 1.01)  // Slight detune
    return [left, right]
}

// Stereo effect
let stereoEffect = OperationEffect(input, channelCount: 2) { stereoInput, parameters in
    let left = stereoInput.left.reverberateWithCostello(feedback: 0.6)
    let right = stereoInput.right.reverberateWithCostello(feedback: 0.6)
    return [left, right]
}
```

### Available Operation Generators

#### Oscillators
```swift
// Sine wave
Operation.sineWave(frequency: 440, amplitude: 1.0)

// Sawtooth (band-limited)
Operation.sawtoothWave(frequency: 440, amplitude: 0.5)

// Square wave (band-limited, with pulse width)
Operation.squareWave(frequency: 440, amplitude: 1.0, pulseWidth: 0.5)

// Triangle wave (band-limited)
Operation.triangleWave(frequency: 440, amplitude: 0.5)

// Non-band-limited variants (aliasing, but CPU efficient)
Operation.sawtooth(frequency: 440, amplitude: 0.5, phase: 0)
Operation.square(frequency: 440, amplitude: 0.5, phase: 0)
Operation.triangle(frequency: 440, amplitude: 0.5, phase: 0)
Operation.reverseSawtooth(frequency: 440, amplitude: 0.5, phase: 0)

// FM Oscillator
Operation.fmOscillator(
    baseFrequency: 440,
    carrierMultiplier: 1.0,
    modulatingMultiplier: 1.0,
    modulationIndex: 1.0,
    amplitude: 0.5
)

// Morphing Oscillator (interpolates sine -> square -> saw -> reverse saw)
Operation.morphingOscillator(
    frequency: 440,
    amplitude: 1.0,
    index: 0.0  // 0-3: 0=sine, 1=square, 2=saw, 3=reverse saw
)

// Phasor (normalized sawtooth for table lookup)
Operation.phasor(frequency: 1.0, phase: 0)
```

#### Noise Generators
```swift
Operation.whiteNoise(amplitude: 1.0)
Operation.pinkNoise(amplitude: 1.0)
Operation.brownianNoise(amplitude: 1.0)
```

#### Physical Modeling
```swift
// Karplus-Strong plucked string
Operation.pluckedString(
    trigger: Operation.trigger,
    frequency: 110,
    amplitude: 0.5,
    lowestFrequency: 110
)

// Vocal tract synthesizer (CPU intensive!)
Operation.vocalTract(
    frequency: 160,
    tonguePosition: 0.5,
    tongueDiameter: 1.0,
    tenseness: 0.6,
    nasality: 0.0
)
```

#### Drum Synths
```swift
// Kick drum
SynthKick()  // Uses lineSegment + sineWave + moogLadderFilter

// Snare drum
SynthSnare()  // Uses whiteNoise + lineSegment + moogLadderFilter
```

### Available Operation Effects (Filters)

```swift
// Moog Ladder Filter (classic analog sound)
input.moogLadderFilter(
    cutoffFrequency: 1000,  // 12-20000 Hz
    resonance: 0.5          // 0-2
)

// Korg 35 Filter (MS-20 style)
input.korgLowPassFilter(
    cutoffFrequency: 1000,  // 0-22050 Hz
    resonance: 1.0,         // 0-2
    saturation: 0           // 0-10
)

// Three-Pole Low Pass with distortion
input.threePoleLowPassFilter(
    distortion: 0.5,        // 0-2
    cutoffFrequency: 1500,  // 12-20000 Hz
    resonance: 0.5          // 0-2
)

// Butterworth filters
input.lowPassButterworthFilter(cutoffFrequency: 1000)
input.highPassButterworthFilter(cutoffFrequency: 500)

// Simple first-order filters
input.lowPassFilter(halfPowerPoint: 1000)
input.highPassFilter(halfPowerPoint: 1000)

// Resonant filter
input.resonantFilter(frequency: 4000, bandwidth: 1000)

// Modal resonance filter (for physical modeling)
input.modalResonanceFilter(frequency: 500, qualityFactor: 50)

// String resonator
input.stringResonator(frequency: 100, feedback: 0.95)

// Auto-wah
input.autoWah(wah: 0.5, amplitude: 0.1)

// DC blocking
input.dcBlock()
```

### Available Operation Effects (Delay)

```swift
// Basic delay
input.delay(time: 1.0, feedback: 0.5)

// Smooth delay (no pitch shifting when time changes)
input.smoothDelay(
    time: 1.0,
    feedback: 0.5,
    samples: 1024,
    maximumDelayTime: 5.0
)

// Variable delay (cubic interpolation)
input.variableDelay(
    time: 1.0,
    feedback: 0.5,
    maximumDelayTime: 5.0
)
```

### Available Operation Effects (Reverb)

```swift
// Chowning reverb (allpass + comb)
input.reverberateWithChowning()

// Comb filter reverb
input.reverberateWithCombFilter(
    reverbDuration: 1.0,  // decay to -60dB
    loopDuration: 0.1
)

// Costello reverb (stereo FDN, returns StereoOperation)
input.reverberateWithCostello(
    feedback: 0.6,           // 0-1, higher = larger hall
    cutoffFrequency: 4000    // low-pass filter
)

// Flat frequency response reverb
input.reverberateWithFlatFrequencyResponse(
    reverbDuration: 0.5,
    loopDuration: 0.1
)
```

### Available Operation Effects (Distortion)

```swift
// Hyperbolic tangent distortion
input.distort(
    pregain: 2.0,                  // gain before waveshaping (0-10)
    postgain: 0.5,                 // gain after waveshaping (0-10)
    positiveShapeParameter: 0.0,   // shape for positive signal (-10 to 10)
    negativeShapeParameter: 0.0    // shape for negative signal (-10 to 10)
)
```

### Complex Operation Example: FM Synth

```swift
import SporthAudioKit

class FMSynthConductor: ObservableObject {
    let engine = AudioEngine()
    let generator: OperationGenerator

    @Published var carrierFrequency: AUValue = 440 {
        didSet { generator.parameter1 = carrierFrequency }
    }
    @Published var modulatorRatio: AUValue = 2.0 {
        didSet { generator.parameter2 = modulatorRatio }
    }
    @Published var modulationIndex: AUValue = 1.0 {
        didSet { generator.parameter3 = modulationIndex }
    }
    @Published var amplitude: AUValue = 0.5 {
        didSet { generator.parameter4 = amplitude }
    }

    init() {
        generator = OperationGenerator { params in
            let carrier = params[0]
            let ratio = params[1]
            let index = params[2]
            let amp = params[3]

            return Operation.fmOscillator(
                baseFrequency: carrier,
                carrierMultiplier: 1.0,
                modulatingMultiplier: ratio,
                modulationIndex: index,
                amplitude: amp
            )
        }

        generator.parameter1 = carrierFrequency
        generator.parameter2 = modulatorRatio
        generator.parameter3 = modulationIndex
        generator.parameter4 = amplitude

        let reverb = Reverb(generator)
        reverb.dryWetMix = 0.2
        engine.output = reverb
    }

    func start() {
        do {
            try engine.start()
            generator.start()
        } catch {
            Log("Engine failed to start")
        }
    }

    func stop() {
        generator.stop()
    }
}
```

### Complex Operation Example: Filter Envelope Effect

```swift
import SporthAudioKit

// Create a filter with envelope modulation
let filterEffect = OperationEffect(oscillator, channelCount: 1) { input, params in
    let baseCutoff = params[0]      // Base cutoff frequency
    let envelopeAmount = params[1]  // How much envelope affects cutoff
    let resonance = params[2]

    // Create envelope that responds to amplitude
    let envelope = input.trackedAmplitude()

    // Modulate cutoff with envelope
    let cutoff = baseCutoff + (envelope * envelopeAmount * 10000)

    return input.moogLadderFilter(
        cutoffFrequency: cutoff,
        resonance: resonance
    )
}

filterEffect.parameter1 = 200   // base cutoff
filterEffect.parameter2 = 0.5   // envelope amount
filterEffect.parameter3 = 0.7   // resonance
```

---

## Project Architecture (AUv3-Compatible)

### Required Project Structure

```
YourProject/
├── YourProject/                          # Main app target
│   ├── YourProjectApp.swift             # App entry point + Settings
│   ├── YourProjectView.swift            # Main SwiftUI view
│   ├── Conductor.swift                  # Audio engine manager
│   ├── ParameterSlider.swift            # Reusable UI component
│   └── SwiftUIKeyboard.swift            # Piano keyboard wrapper
├── YourProjectAUv3/                     # AUv3 extension target
│   ├── Audio Unit/
│   │   └── YourProjectAUv3AudioUnit.swift  # Audio unit implementation
│   ├── UI/
│   │   ├── AudioUnitViewController.swift   # SwiftUI host controller
│   │   └── YourProjectAUv3View.swift       # Extension SwiftUI view
│   └── Info.plist                       # Audio Unit configuration
└── Sounds/                              # Audio assets (shared)
```

### Info.plist Configuration (AUv3)

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>AudioComponents</key>
        <array>
            <dict>
                <key>type</key>
                <string>aumu</string>           <!-- aumu = Music Instrument -->
                <key>subtype</key>
                <string>syn1</string>           <!-- 4-char unique identifier -->
                <key>manufacturer</key>
                <string>TEST</string>           <!-- 4-char manufacturer code -->
                <key>name</key>
                <string>TEST: YourSynth</string>
                <key>description</key>
                <string>YourSynthAUv3</string>
                <key>factoryFunction</key>
                <string>$(PRODUCT_MODULE_NAME).AudioUnitViewController</string>
                <key>sandboxSafe</key>
                <true/>
                <key>tags</key>
                <array>
                    <string>Synthesizer</string>
                </array>
                <key>version</key>
                <integer>67072</integer>
            </dict>
        </array>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.AudioUnit-UI</string>
</dict>
```

**Audio Unit Types:**
- `aumu` - Music Instrument (generates sound from MIDI)
- `aufx` - Effect (processes audio input)
- `aumi` - MIDI Processor (transforms MIDI)
- `aumc` - Music Effect (MIDI + audio input)

---

## Core Implementation Patterns

### 1. App Entry Point (YourProjectApp.swift)

```swift
import SwiftUI
import AVFoundation
import AudioKit

@main
struct YourProjectApp: App {

    init() {
        #if os(iOS)
        do {
            // Platform-specific sample rate
            if #available(iOS 18.0, *) {
                if !ProcessInfo.processInfo.isMacCatalystApp &&
                   !ProcessInfo.processInfo.isiOSAppOnMac {
                    Settings.sampleRate = 48_000
                }
            }
            if #available(macOS 15.0, *) {
                Settings.sampleRate = 48_000
            }

            Settings.bufferLength = .medium
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(
                Settings.bufferLength.duration
            )
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            print(err)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            YourProjectView()
        }
    }
}
```

### 2. Conductor Pattern (Conductor.swift)

```swift
import AudioKit
import AVFoundation

class Conductor: ObservableObject {
    let engine = AudioEngine()
    var instrument = MIDISampler(name: "Instrument 1")
    @Published var reverb: Reverb

    init() {
        // Build audio chain: Source -> Effects -> Output
        reverb = Reverb(instrument)
        reverb.dryWetMix = 0.3
        engine.output = reverb
    }

    func start() {
        // Load samples
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/Instrument",
                                             withExtension: "exs") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }

        // Start engine
        do {
            try engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }

    func stop() {
        engine.stop()
    }
}
```

### 3. Main View with MIDI (YourProjectView.swift)

```swift
import AudioKit
import AVFoundation
import SwiftUI
import Keyboard
import Tonic

class YourProjectConductor: ObservableObject {
    @Published var conductor = Conductor()
    let midi = MIDI()

    func noteOn(pitch: Pitch, point: CGPoint) {
        conductor.instrument.play(
            noteNumber: MIDINoteNumber(pitch.intValue),
            velocity: 90,
            channel: 0
        )
    }

    func noteOff(pitch: Pitch) {
        conductor.instrument.stop(
            noteNumber: MIDINoteNumber(pitch.intValue),
            channel: 0
        )
    }

    init() {
        midi.addListener(self)
    }

    func start() {
        conductor.start()
        midi.openInput()
    }

    func stop() {
        conductor.stop()
        midi.closeAllInputs()
    }
}

struct YourProjectView: View {
    @StateObject var projectConductor = YourProjectConductor()
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    var backgroundMode = true

    var body: some View {
        VStack {
            ParameterSlider(
                text: "Reverb",
                parameter: $projectConductor.conductor.reverb.dryWetMix,
                range: 0...1,
                units: "Percent"
            ).padding(10)

            Spacer()

            SwiftUIKeyboard(
                firstOctave: 2,
                octaveCount: 2,
                noteOn: projectConductor.noteOn(pitch:point:),
                noteOff: projectConductor.noteOff
            )
            .frame(maxHeight: 600)
            .padding(10)
        }
        .onAppear {
            if !projectConductor.conductor.engine.avEngine.isRunning {
                Log("Engine Starting")
                projectConductor.start()
            }
        }
        // Background audio handling
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if !projectConductor.conductor.engine.avEngine.isRunning {
                    projectConductor.start()
                }
            } else if newPhase == .background {
                if !backgroundMode {
                    projectConductor.stop()
                }
            }
        }
        // Phone call interruption handling
        .onReceive(NotificationCenter.default.publisher(
            for: AVAudioSession.interruptionNotification
        )) { event in
            guard let info = event.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }

            if type == .began {
                projectConductor.stop()
            } else if type == .ended {
                guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt
                else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    if !projectConductor.conductor.engine.avEngine.isRunning {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            projectConductor.start()
                        }
                    }
                }
            }
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

// MARK: - MIDIListener Extension
extension YourProjectConductor: MIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity,
                           channel: MIDIChannel, portID: MIDIUniqueID?,
                           timeStamp: MIDITimeStamp?) {
        conductor.instrument.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity,
                            channel: MIDIChannel, portID: MIDIUniqueID?,
                            timeStamp: MIDITimeStamp?) {
        conductor.instrument.stop(noteNumber: noteNumber, channel: channel)
    }

    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte,
                               channel: MIDIChannel, portID: MIDIUniqueID?,
                               timeStamp: MIDITimeStamp?) {
        conductor.instrument.midiCC(1, value: value, channel: channel)
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel,
                               portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        conductor.instrument.setPitchbend(amount: pitchWheelValue, channel: channel)
    }

    // Required protocol stubs
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte,
                               channel: MIDIChannel, portID: MIDIUniqueID?,
                               timeStamp: MIDITimeStamp?) {}
    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel,
                               portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel,
                                  portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {}
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?,
                                  timeStamp: MIDITimeStamp?) {}
    func receivedMIDISetupChange() {}
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {}
    func receivedMIDINotification(notification: MIDINotification) {}
}
```

---

## AUv3 Audio Unit Implementation

### 4. Audio Unit (YourProjectAUv3AudioUnit.swift)

```swift
import Foundation
import AudioToolbox
import AVFoundation
import CoreAudioKit
import AudioKit

public class YourProjectAUv3AudioUnit: AUAudioUnit {

    var engine: AVAudioEngine!
    var conductor: Conductor!
    var paramTree = AUParameterTree()
    private var _currentPreset: AUAudioUnitPreset?
    private var confirmEngineStarted = false
    private var doneLoading = false

    // Define parameters
    var reverbParam = AUParameterTree.createParameter(
        withIdentifier: "reverb",
        name: "Reverb",
        address: 0,
        min: 0.0,
        max: 1.0,
        unit: .generic,
        unitName: nil,
        flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
        valueStrings: nil,
        dependentParameters: nil
    )

    public override init(componentDescription: AudioComponentDescription,
                        options: AudioComponentInstantiationOptions = []) throws {
        conductor = Conductor()
        engine = conductor.engine.avEngine

        do {
            try super.init(componentDescription: componentDescription, options: options)
            try setOutputBusArrays()
        } catch {
            Log("Could not init audio unit")
            throw error
        }

        setupParamTree()
        setupParamCallbacks()
        setInternalRenderingBlock()
        log(componentDescription)
    }

    // MARK: - Factory Presets

    public override var factoryPresets: [AUAudioUnitPreset] {
        return [
            AUAudioUnitPreset(number: 0, name: "Dry"),
            AUAudioUnitPreset(number: 1, name: "Wet")
        ]
    }

    public override var currentPreset: AUAudioUnitPreset? {
        get { return _currentPreset }
        set {
            guard let preset = newValue else {
                _currentPreset = nil
                return
            }
            if preset.number >= 0 {
                _currentPreset = preset
                switch preset.number {
                case 0: reverbParam.value = 0
                case 1: reverbParam.value = 1
                default: break
                }
            } else {
                do {
                    fullStateForDocument = try presetState(for: preset)
                    _currentPreset = preset
                } catch {
                    print("Unable to restore preset \(preset.name)")
                }
            }
        }
    }

    override public var supportsUserPresets: Bool { return false }

    // MARK: - Parameter Setup

    public func setupParamTree() {
        reverbParam.value = 0.3
        parameterTree = AUParameterTree.createTree(withChildren: [reverbParam])
    }

    public func setupParamCallbacks() {
        parameterTree?.implementorValueObserver = { param, value in
            switch param.identifier {
            case "reverb":
                self.conductor.reverb.dryWetMix = value
            default:
                break
            }
        }
    }

    // MARK: - Event Handling

    private func handleEvents(eventsList: AURenderEvent?,
                             timestamp: UnsafePointer<AudioTimeStamp>) {
        var nextEvent = eventsList
        while nextEvent != nil {
            if nextEvent!.head.eventType == .MIDI {
                handleMIDI(midiEvent: nextEvent!.MIDI, timestamp: timestamp)
            } else if nextEvent!.head.eventType == .parameter ||
                      nextEvent!.head.eventType == .parameterRamp {
                handleParameter(parameterEvent: nextEvent!.parameter, timestamp: timestamp)
            }
            nextEvent = nextEvent!.head.next?.pointee
        }
    }

    private func handleParameter(parameterEvent event: AUParameterEvent,
                                timestamp: UnsafePointer<AudioTimeStamp>) {
        parameterTree?.parameter(withAddress: event.parameterAddress)?.value = event.value
    }

    private func handleMIDI(midiEvent event: AUMIDIEvent,
                           timestamp: UnsafePointer<AudioTimeStamp>) {
        let diff = Float64(event.eventSampleTime) - timestamp.pointee.mSampleTime
        let offset = MIDITimeStamp(UInt32(max(0, diff)))
        let midiEvent = MIDIEvent(data: [event.data.0, event.data.1, event.data.2])
        guard let statusType = midiEvent.status?.type else { return }

        switch statusType {
        case .noteOn:
            if midiEvent.data[2] == 0 {
                receivedMIDINoteOff(noteNumber: event.data.1,
                                   channel: midiEvent.channel ?? 0, offset: offset)
            } else {
                receivedMIDINoteOn(noteNumber: event.data.1, velocity: event.data.2,
                                  channel: midiEvent.channel ?? 0, offset: offset)
            }
        case .noteOff:
            receivedMIDINoteOff(noteNumber: event.data.1,
                               channel: midiEvent.channel ?? 0, offset: offset)
        case .controllerChange:
            conductor.instrument.midiCC(event.data.1, value: event.data.2,
                                       channel: midiEvent.channel ?? 0)
        case .pitchWheel:
            if let pitchAmount = midiEvent.pitchbendAmount,
               let channel = midiEvent.channel {
                conductor.instrument.setPitchbend(amount: pitchAmount, channel: channel)
            }
        default:
            Log("Unhandled MIDI event: \(statusType)")
        }
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity,
                           channel: MIDIChannel, offset: MIDITimeStamp) {
        if !doneLoading { return }

        if !confirmEngineStarted && !engine.isRunning {
            engineStart()
        } else {
            confirmEngineStarted = true
        }

        if confirmEngineStarted {
            conductor.instrument.play(noteNumber: noteNumber,
                                     velocity: velocity, channel: channel)
        } else {
            DispatchQueue.main.async {
                self.conductor.instrument.play(noteNumber: noteNumber,
                                              velocity: velocity, channel: channel)
            }
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                            channel: MIDIChannel, offset: MIDITimeStamp) {
        conductor.instrument.stop(noteNumber: noteNumber, channel: channel)
    }

    // MARK: - Render Block

    private func setInternalRenderingBlock() {
        self._internalRenderBlock = { [weak self] (actionFlags, timestamp, frameCount,
                                                   outputBusNumber, outputData,
                                                   renderEvent, pullInputBlock) in
            guard let self = self else { return 1 }

            if let eventList = renderEvent?.pointee {
                self.handleEvents(eventsList: eventList, timestamp: timestamp)
            }

            _ = self.engine.manualRenderingBlock(frameCount, outputData, nil)
            return noErr
        }
    }

    // MARK: - Lifecycle

    override public func allocateRenderResources() throws {
        do {
            try engine.enableManualRenderingMode(.offline,
                                                format: outputBus.format,
                                                maximumFrameCount: 4096)
            engineStart()
            try super.allocateRenderResources()
            confirmEngineStarted = false
            doneLoading = true
        } catch {
            return
        }
        self.mcb = self.musicalContextBlock
        self.tsb = self.transportStateBlock
        self.moeb = self.midiOutputEventBlock
    }

    func engineStart() {
        conductor.start()
    }

    override public func deallocateRenderResources() {
        engine.stop()
        confirmEngineStarted = false
        super.deallocateRenderResources()
        self.mcb = nil
        self.tsb = nil
        self.moeb = nil
    }

    // MARK: - Audio Unit Properties

    public override var canProcessInPlace: Bool { return true }

    var mcb: AUHostMusicalContextBlock?
    var tsb: AUHostTransportStateBlock?
    var moeb: AUMIDIOutputEventBlock?

    open var _parameterTree: AUParameterTree!
    override open var parameterTree: AUParameterTree? {
        get { return self._parameterTree }
        set { _parameterTree = newValue }
    }

    open var _internalRenderBlock: AUInternalRenderBlock!
    override open var internalRenderBlock: AUInternalRenderBlock {
        return self._internalRenderBlock
    }

    var outputBus: AUAudioUnitBus!
    open var _outputBusArray: AUAudioUnitBusArray!
    override open var outputBusses: AUAudioUnitBusArray {
        return self._outputBusArray
    }

    open func setOutputBusArrays() throws {
        let defaultAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        outputBus = try AUAudioUnitBus(format: defaultAudioFormat!)
        self._outputBusArray = AUAudioUnitBusArray(audioUnit: self,
                                                   busType: .output,
                                                   busses: [outputBus])
    }

    override open func supportedViewConfigurations(
        _ availableViewConfigurations: [AUAudioUnitViewConfiguration]
    ) -> IndexSet {
        return IndexSet(availableViewConfigurations.indices)
    }

    private func log(_ acd: AudioComponentDescription) {
        let info = ProcessInfo.processInfo
        print("\nProcess Name: \(info.processName) PID: \(info.processIdentifier)\n")
        print("""
        Audio Unit (
            type: \(acd.componentType.stringValue)
            subtype: \(acd.componentSubType.stringValue)
            manufacturer: \(acd.componentManufacturer.stringValue)
        )
        """)
    }
}

// MARK: - Helper Extensions

fileprivate extension AUAudioUnitPreset {
    convenience init(number: Int, name: String) {
        self.init()
        self.number = number
        self.name = name
    }
}

extension FourCharCode {
    var stringValue: String {
        let value = CFSwapInt32BigToHost(self)
        let bytes = [0, 8, 16, 24].map { UInt8(value >> $0 & 0x000000FF) }
        guard let result = String(bytes: bytes, encoding: .macOSRoman) else {
            return "fail"
        }
        return result
    }
}
```

### 5. AudioUnitViewController (Cross-Platform SwiftUI Host)

```swift
import CoreAudioKit
import SwiftUI

#if os(iOS)
typealias HostingController = UIHostingController
#elseif os(macOS)
typealias HostingController = NSHostingController

extension NSView {
    func bringSubviewToFront(_ view: NSView) {}
}
#endif

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    var hostingController: HostingController<YourProjectAUv3View>?
    var parameterObserverToken: AUParameterObserverToken?
    var observer: NSKeyValueObservation?
    var needsConnection = true

    var reverbParameter: AUParameter?

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let audioUnit = audioUnit else { return }
        setupParameterObservation()
        configureSwiftUIView(audioUnit: audioUnit)
    }

    private func setupParameterObservation() {
        guard needsConnection, let paramTree = audioUnit?.parameterTree else { return }

        reverbParameter = paramTree.value(forKey: "reverb") as? AUParameter

        observer = audioUnit?.observe(\.allParameterValues) { object, change in
            DispatchQueue.main.async { }
        }

        parameterObserverToken = paramTree.token(byAddingParameterObserver: {
            [weak self] address, value in
            guard let self = self,
                  address == self.reverbParameter?.address else { return }
            DispatchQueue.main.async {
                self.hostingController?.rootView.updateParameterValue(value)
            }
        })

        needsConnection = false
    }

    public func createAudioUnit(
        with componentDescription: AudioComponentDescription
    ) throws -> AUAudioUnit {
        audioUnit = try YourProjectAUv3AudioUnit(
            componentDescription: componentDescription,
            options: []
        )
        DispatchQueue.main.async {
            self.setupParameterObservation()
            self.configureSwiftUIView(audioUnit: self.audioUnit!)
        }
        return audioUnit!
    }

    private func configureSwiftUIView(audioUnit: AUAudioUnit) {
        guard let reverbParameter = reverbParameter else { return }

        let audioParameter = AudioParameter(
            auParameter: reverbParameter,
            initialValue: reverbParameter.value
        )
        let contentView = YourProjectAUv3View(audioParameter: audioParameter)
        let hostingController = HostingController(rootView: contentView)

        if let existingHost = self.hostingController {
            existingHost.removeFromParent()
            existingHost.view.removeFromSuperview()
        }

        self.addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        self.view.addSubview(hostingController.view)
        self.hostingController = hostingController

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
```

### 6. AUv3 SwiftUI View (YourProjectAUv3View.swift)

```swift
import CoreAudioKit
import SwiftUI

class AudioParameter: ObservableObject {
    @Published var value: AUValue
    var auParameter: AUParameter

    init(auParameter: AUParameter, initialValue: AUValue) {
        self.auParameter = auParameter
        self.value = initialValue
    }

    func updateValue(_ newValue: AUValue) {
        DispatchQueue.main.async {
            self.value = newValue
            self.auParameter.setValue(newValue, originator: nil)
        }
    }
}

struct YourProjectAUv3View: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var audioParameter: AudioParameter

    func updateParameterValue(_ value: AUValue) {
        DispatchQueue.main.async {
            self.audioParameter.value = value
        }
    }

    var body: some View {
        VStack {
            ParameterSlider(
                text: "Reverb",
                parameter: $audioParameter.value,
                range: 0...1,
                units: "Percent"
            )
            .padding(10)
            .onChange(of: audioParameter.value) { newValue in
                audioParameter.updateValue(newValue)
            }
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}
```

---

## Shared UI Components

### ParameterSlider.swift

```swift
import AVFoundation
import SwiftUI

struct ParameterSlider: View {
    var text: String
    @Binding var parameter: AUValue
    var range: ClosedRange<AUValue>
    var format: String = "%0.2f"
    var units: String = ""

    var body: some View {
        VStack {
            HStack {
                Text(self.text)
                Spacer()
                if units == "" || units == "Generic" {
                    Text("\(self.parameter, specifier: self.format)")
                } else if units == "%" || units == "Percent" {
                    Text("\(self.parameter * 100, specifier: "%0.f")%")
                } else if units == "Percent-0-100" {
                    Text("\(self.parameter, specifier: "%0.f")%")
                } else if units == "Hertz" {
                    Text("\(self.parameter, specifier: "%0.2f") Hz")
                } else {
                    Text("\(self.parameter, specifier: self.format) \(units)")
                }
            }
            Slider(value: self.$parameter, in: self.range)
        }
    }
}
```

### SwiftUIKeyboard.swift

```swift
import Foundation
import SwiftUI
import Keyboard
import Tonic
import AudioKit
import AVFoundation

struct SwiftUIKeyboard: View {
    var firstOctave: Int
    var octaveCount: Int
    var noteOn: (Pitch, CGPoint) -> Void = { _, _ in }
    var noteOff: (Pitch) -> Void

    var body: some View {
        Keyboard(
            layout: .piano(
                pitchRange: Pitch(intValue: firstOctave * 12 + 24)...
                           Pitch(intValue: firstOctave * 12 + octaveCount * 12 + 24)
            ),
            noteOn: noteOn,
            noteOff: noteOff
        ) { pitch, isActivated in
            KeyboardKey(
                pitch: pitch,
                isActivated: isActivated,
                text: "",
                pressedColor: Color.pink,
                flatTop: true
            )
        }
        .cornerRadius(5)
    }
}
```

---

## SoundpipeAudioKit DSP Nodes

### Oscillators

```swift
import SoundpipeAudioKit

// Dynamic Oscillator - switchable waveforms
let osc = DynamicOscillator()
osc.frequency = 440
osc.amplitude = 0.5
osc.setWaveform(Table(.sine))  // .sine, .triangle, .square, .sawtooth

// FM Oscillator
let fm = FMOscillator()
fm.baseFrequency = 440
fm.carrierMultiplier = 1.0
fm.modulatingMultiplier = 1.0
fm.modulationIndex = 1.0

// PWM Oscillator
let pwm = PWMOscillator()
pwm.frequency = 440
pwm.pulseWidth = 0.5

// Morphing Oscillator
let morph = MorphingOscillator()
morph.frequency = 440
morph.index = 0.5
```

### Filters

```swift
import SoundpipeAudioKit

// Moog Ladder Filter
let moog = MoogLadder(input)
moog.cutoffFrequency = 1000
moog.resonance = 0.5

// Korg 35 Filter
let korg = Korg35Filter(input)
korg.cutoffFrequency = 1000
korg.resonance = 0.5
korg.saturation = 0.0

// Roland TB-303 Filter
let tb303 = RolandTB303Filter(input)
tb303.cutoffFrequency = 1000
tb303.resonance = 0.5
```

### Envelopes

```swift
import SoundpipeAudioKit

let envelope = AmplitudeEnvelope(oscillator)
envelope.attackDuration = 0.1
envelope.decayDuration = 0.2
envelope.sustainLevel = 0.7
envelope.releaseDuration = 0.5

envelope.start()  // Begin attack
envelope.stop()   // Begin release
```

---

## Real-Time Thread Safety Rules

### NEVER do in render callback:
- Allocate memory (`Array()`, `String()`, `NSObject()`)
- Use locks (`DispatchSemaphore`, `NSLock`, `pthread_mutex`)
- Call Objective-C methods (they use locks internally)
- Access disk or network
- Update `@Published` properties directly
- Call `Log()` or `print()`

### SAFE in render callback:
- Read/write pre-allocated buffers
- Simple arithmetic
- Call AudioKit DSP node methods
- Read atomic values

---

## When to Use What

**Use SoundpipeAudioKit nodes when:**
- You need individual DSP building blocks
- Standard synthesis patterns
- Maximum control over each component

**Use SporthAudioKit Operations when:**
- Building complex interconnected DSP graphs
- Creating custom generators/effects
- Need dynamic parameter routing
- Combining multiple operations efficiently

**Use AudioKit core nodes when:**
- Sample playback (MIDISampler)
- Basic effects (Reverb, Delay)
- Simple synthesis

For most samplers, synthesizers, and sequencers, the combination of AudioKit + SoundpipeAudioKit + SporthAudioKit provides everything needed.
