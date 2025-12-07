# Claude Code AUv3 Development Config

Claude Code configuration files for AudioKit AUv3 instrument development.

## Contents

- **skills/** - Knowledge bases that agents can reference
  - `audiokit-dsp.md` - Comprehensive AudioKit 5 DSP reference (SoundpipeAudioKit, SporthAudioKit Operations, AUv3 patterns)

- **commands/** - Slash commands for common tasks
  - `create-auv3.md` - `/create-auv3 ProjectName` to scaffold a new AUv3 project

- **agents/** - Specialized AI agents that work as a team
  - `auv3-coordinator.md` - Primary entry point, orchestrates the team
  - `auv3-architect.md` - Designs signal flow and parameters
  - `auv3-dsp-engineer.md` - Implements audio processing
  - `auv3-ui-designer.md` - Creates hardware-inspired SwiftUI UIs
  - `auv3-integrator.md` - Handles AUv3 boilerplate and MIDI

## Installation

Run the install script to copy files to your `~/.claude/` directory:

```bash
curl -fsSL https://raw.githubusercontent.com/hagenkaiser/claude-code-auv3/main/install.sh | bash
```

Or manually copy the directories:

```bash
git clone https://github.com/hagenkaiser/claude-code-auv3.git
cp -r claude-code-auv3/skills/* ~/.claude/skills/
cp -r claude-code-auv3/commands/* ~/.claude/commands/
cp -r claude-code-auv3/agents/* ~/.claude/agents/
```

## Usage

### Creating a New AUv3 Instrument

Simply tell Claude Code what you want to build:

> "I want to create a subtractive synth with 2 oscillators and a filter"

The **auv3-coordinator** agent will automatically:
1. Create the project scaffold
2. Gather your requirements
3. Launch the architect to design the audio signal flow
4. Deploy DSP engineer, UI designer, and integrator in parallel
5. Assemble and verify the final build

### Using the Command

You can also use the slash command directly:

```
/create-auv3 MySynth
```

This creates a new project and offers to engage the development team.

## Related Repos

- [auv3-template-setup](https://github.com/hagenkaiser/auv3-template-setup) - Setup script for scaffolding projects
- [AudioKitTemplate](https://github.com/hagenkaiser/AudioKitTemplate) - The project template itself
