# CtrlSpace

CtrlSpace is a hotstring manager for Windows designed to streamline the hassle of editing an AutoHotkey script and reloading it.

This tool automates frequent text entries, enhancing productivity in tasks such as customer support, form filling, and repetitive messaging.

## Features

- **Quick Hotstring Management**: Create and edit hotstrings with `Ctrl+Space`.
- **Efficient Use**: Activate hotstrings by typing the trigger followed by space or enter.
![1](https://github.com/user-attachments/assets/ec15ae07-9073-4093-a5a2-abe4ff70a85f)
## Installation

1. **Install AutoHotkey**: Download from [autohotkey.com](https://www.autohotkey.com) and install.
2. **Set Up CtrlSpace**: 
   - Create a folder (e.g., `OneDrive\Documents\CtrlSpace`).
   - Download `CtrlSpace.ahk` from this repository and place it in that folder.
3. **Run CtrlSpace**: Double-click `CtrlSpace.ahk` to start. Right click the tray icon to Exit.

   ![image](https://github.com/user-attachments/assets/7b731dc7-48c3-4e70-abd1-01871a91357d)


## Usage

Type the trigger text (also called hotstring in the Autohotkey documentation) and press `Ctrl+Space` to edit. Type the trigger key followed by space to activate a hotstring.

## Notes

Avoid storing sensitive information like passwords, as data is stored in plain text.

Also avoid creating macros that press ENTER. If you absolutely want to save a test with many lines, use an uncommon prefix to avoid accidental triggers (e.g., `~recoversteps` instead of `,recoversteps`).

This is not meant to be a collaborative tool.
