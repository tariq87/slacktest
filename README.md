# slacktest
This is Jumbo - a very simple implementation of a very popular config management tool Ansible
It uses ssh protocol to configure any given number of servers.
For now it only works for debian based systems but code can be modified to suit any OS.

Requirement:
- Ruby - if you do not have ruby installed, use the bootstrap script provided to install and set ruby on your system.
Usage:
Jumbo is very simple to use config management tool.
- Clone the repository in any folder.
- Rename jumbo.rb to jumbo
- Move the file to system path (/usr/bin or /bin or /usr/local/bin)
- jumbo -h - to get the help menu


Required Files:
1) Hostfile - contains the list of hosts you want to configure, nothing special here, just a text file with list of ip addresses.
2) ConfigFile - describes the state of the machine, an example file is provided in the repo.

Future Enhancements:
Since jumbo is in very nascent state, there is room for a lot of improvement and several features can be added to enhance its capabilities, a few which I have in my mind are.
- Parallel ssh capability
- Adding more configuration options
- Adding support for multiple operating systems
