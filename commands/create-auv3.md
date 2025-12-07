# Create AUv3 Project

Create a new AudioKit AUv3 instrument project using the template, then optionally engage the AUv3 development team to build it out.

## Arguments
- $ARGUMENTS: Project configuration in format: "ProjectName [destination_dir]"
  - ProjectName: Required. Use PascalCase (e.g., "MySynth", "BassStation")
  - destination_dir: Optional. Defaults to current working directory

## Instructions

### Step 1: Parse Arguments
- First word is the project name (required, must be valid Swift identifier)
- Second word is the destination directory (optional, defaults to ".")
- Generate a unique 4-character subtype code from the project name (first 4 lowercase letters, or generate if name is too short)

### Step 2: Download and Run Setup Script

```bash
curl -fsSL https://raw.githubusercontent.com/hagenkaiser/auv3-template-setup/main/setup-template.sh -o /tmp/setup-template.sh
chmod +x /tmp/setup-template.sh
```

### Step 3: Execute with Project Configuration

The script prompts for these values (provide via stdin):
1. Project name (from arguments)
2. Bundle identifier prefix: "com.hagenkaiser"
3. Manufacturer code: "HGKR"
4. Subtype code: Generate from project name (first 4 chars lowercase, e.g., "MySynth" → "mysy")
5. Destination directory: From arguments or "."

Run:
```bash
printf '%s\n' "<project_name>" "com.hagenkaiser" "HGKR" "<subtype>" "<destination>" | /tmp/setup-template.sh
```

### Step 4: Clean Up Template Files

After the script completes, remove unnecessary template files from the new project:
```bash
rm -f <project_path>/setup-template.sh
rm -f <project_path>/TEMPLATE_README.md
```

### Step 5: Report Success

Inform the user:
- Project location (full path)
- Project name
- Bundle ID: com.hagenkaiser.<ProjectName>
- Manufacturer code: HGKR
- Subtype code: <generated>

### Step 6: Offer Development Team

Ask the user if they want to engage the AUv3 development team to build out the instrument:

"Your AUv3 project is ready! Would you like me to engage the development team to design and build the instrument?

The team includes:
- **Architect** - Design signal flow and parameters
- **DSP Engineer** - Implement audio processing
- **UI Designer** - Create hardware-inspired interface
- **Integrator** - Wire everything together

Just describe what kind of instrument you want to build (e.g., 'subtractive synth with 2 oscillators and a filter' or 'drum sampler with 8 pads')."

If the user wants to proceed, use the `auv3-coordinator` agent to orchestrate the build.

## Notes
- The template uses AudioKit 5 from main branch
- Projects are created with SwiftUI for both standalone app and AUv3 extension
- iPad-optimized by default
