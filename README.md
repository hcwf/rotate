# rotate.sh
A lightweight and simple backup tool supporting rotating backups and compression of backups.

## Usage

`rotate.sh [OPTIONS] <FILE>`

### Options

`-b <N>` --> Sets the number of backups to keep to N.
- Minimum = 1 
- Default = 5 
- Maximum = 9

`-d` --> Delete all backups for `<FILE>`.

`-h` --> Displays the help message.
	
`-l` --> Lists `<FILE>` and all backups for `<FILE>`.

`-z` --> GZIPs the backup of `<FILE>`.

Only -b and -z can be used with one another, other combinations throw an error.