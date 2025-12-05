# GNS - Goblin Naming System

A Turtle WoW addon that adds custom naming functionality to the Goblin Brainwashing Device specializations.

## Features

- **Custom Specialization Names**: Assign friendly names to each of your 4 talent specializations
- **Automatic Display**: Custom names appear in the "Activate" lines of the Goblin Brainwashing Device interface
- **Per-Character Storage**: Each character maintains their own set of custom names
- **Persistent Names**: Names are saved across sessions in the `GNS_SpecNames` saved variable
- **Easy Renaming**: Use simple slash commands to rename any specialization at any time

## Usage

### Viewing Current Names

Type `/gns` or `/goblinname` to see all your current specialization names:

```
/gns
```

This displays:
- Current names for all 4 specializations
- Usage instructions

### Renaming a Specialization

To rename a specific specialization (1-4), use:

```
/gns <number>
```

Examples:
- `/gns 1` - Rename specialization 1
- `/gns 2` - Rename specialization 2
- `/gns 3` - Rename specialization 3
- `/gns 4` - Rename specialization 4

A dialog box will appear where you can enter the new name (up to 30 characters).

### In-Game Display

When you interact with the Goblin Brainwashing Device:

**Before (Default):**
- Activate 1st Specialization (20/31/0)
- Activate 2nd Specialization (31/20/0)
- etc.

**After (With Custom Names):**
- Activate Holy PvP (20/31/0)
- Activate Raid Tank (31/20/0)
- etc.

**Note:** The "Save" lines remain unchanged to preserve default UI behavior.

## Default Names

By default, specializations are named:
- 1st Specialization
- 2nd Specialization
- 3rd Specialization
- 4th Specialization

## Compatibility

- **WoW Version**: 1.12 (Turtle WoW)
- **Lua Version**: 5.0
- **Compatible with**: SimpleActionSets and other Goblin Brainwashing Device addons

## Installation

1. Extract the `GNS` folder to your `Interface\AddOns` directory
2. Restart WoW or reload UI (`/reload`)
3. The addon will automatically load and be ready to use

## Slash Commands

| Command | Description |
|---------|-------------|
| `/gns` | Display current specialization names |
| `/gns <1-4>` | Rename a specific specialization |
| `/goblinname` | Alias for `/gns` |

## Technical Details

- Saved variables are stored per character in `GNS_SpecNames`
- The addon hooks into the `GOSSIP_SHOW` event to modify the interface
- Original button text is preserved for pattern matching
- Works with the delayed update system to ensure compatibility with other addons

## Support

For issues, suggestions, or contributions, please contact the addon author.

## Version History

**v1.0** - Initial release
- Custom naming for all 4 specializations
- Slash command interface
- Per-character name storage
- Automatic display in Goblin Brainwashing Device interface
