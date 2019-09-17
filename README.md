#  FolderTidy

Keep Downloads directory clean by moving apps to `/Applications` and deletes `zip`, `dmg`, and other kruft.

## Installation
This standard Swift package builds a command line tool.

1. git clone this repo
2. `swift package build`
3. Find executable: `.build/debug/FolderTidy`
4. run as `swift run` or just `path/to/FolderTidy`
5. (optionally) add to launchd.plist to schedule automation

## No Warranty
I provide no warranty whatsover. Don’t come at me if this software causes loss of data, steals your wallet, or blows up your house.
