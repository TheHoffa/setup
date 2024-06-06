#!/bin/zsh

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

# Get the current user's home directory
HOME_DIR=$(eval echo ~${SUDO_USER})

# Define the path to the Desktop and the Tools folder
DESKTOP_DIR="$HOME_DIR/Desktop"
TOOLS_DIR="$DESKTOP_DIR/Tools"

# Define the paths for the subdirectories
LINUX_DIR="$TOOLS_DIR/Linux"
WINDOWS_DIR="$TOOLS_DIR/Windows"
TUNNELING_DIR="$TOOLS_DIR/Tunneling"

# Check if the file /etc/os-release exists
if [ -f "/etc/os-release" ]; then
    # Source the file to get the variables
    . /etc/os-release
    echo "${ORANGE}[*]${NC}Checking if you are running Kali Linux ${ORANGE}2024.2"
    # Check if the variable VERSION contains "2024.2"
    if [[ "$VERSION" == "2024.2" ]]; then
        echo "${ORANGE}[*]${NC}You are running Kali Linux ${GREEN}2024.2"
    else
        echo "${ORANGE}[*]${RED}ERROR${NC}: Wrong Kali version!"
        echo -n "${ORANGE}[*]${NC}Do you want to continue anyway? (${GREEN}yes${NC}/${RED}no${NC}): "
        read choice
        case "$choice" in
            yes|YES|y|Y ) echo "Continuing with the setup...";;
            * ) echo "Exiting setup."; exit 1;;
        esac
    fi
else
    echo "${RED}File /etc/os-release not found. This setup is intended for Kali Linux."
    exit 1
fi

# Check if setup has already been ran before
if [ -d "$TOOLS_DIR" ] || [ -d "$DESKTOP_DIR/Stand-Alone-1" ] || [ -d "$DESKTOP_DIR/Stand-Alone-2" ] || [ -d "$DESKTOP_DIR/Stand-Alone-3" ] || [ -d "$DESKTOP_DIR/AD-set" ]; then
    echo ""
    echo "${ORANGE}[*]${NC}One or more of the specified folders already exist."
    echo "${ORANGE}[*]${NC}Please remove or rename the existing folders before running this setup again."
    exit 1
fi

echo "${ORANGE}[*]${NC}This setup will create some folders on your ${ORANGE}desktop${NC}, install some ${ORANGE}tools${NC} on your ${ORANGE}system ${NC}and add some ${ORANGE}aliases${NC} to your ${ORANGE}.zshrc ${NC}file."

# Prompt the user for continuation
echo -n "${ORANGE}[*]${NC}Do you wish to continue? (${GREEN}yes${NC}/${RED}no${NC}): "
read choice
case "$choice" in 
  yes|y ) echo "${ORANGE}[*]${GREEN}Continuing${NC} with the setup...";;
  no|n ) echo "${ORANGE}[*]${RED}Exiting setup."; exit 1;;
  * ) echo "${ORANGE}[*]${RED}Invalid response. Exiting setup.${NC}"; exit 1;;
esac

# Ask for password upfront to avoid repetitive sudo password prompts
echo ""
echo "${ORANGE}[*]${NC}Please enter your ${RED}password${NC} to authenticate for sudo rights during instalation:"
sudo -v

# Check if sudo access is successful
if [ $? -eq 0 ]; then
    echo "${ORANGE}[*]${NC}Authentication ${GREEN}successful${NC}. Proceeding with the setup..."
else
    echo "${ORANGE}[*]${NC}Authentication ${RED}failed${NC}. Exiting setup."
    exit 1
fi

###ZSH MODIFICATION###
# Define the path to the user's .zshrc file
ZSHRC_FILE="$HOME_DIR/.zshrc"
# Append aliases to the .zshrc file
echo "" >> "$ZSHRC_FILE"
echo "##############ALIASES#############" >> "$ZSHRC_FILE"
echo "alias pyserv='ls; python -m http.server 80'" >> "$ZSHRC_FILE"
echo "alias smbserv='sudo impacket-smbserver'" >> "$ZSHRC_FILE"
echo "alias load='sudo xdg-open'" >> "$ZSHRC_FILE"
echo "alias multi='sudo msfconsole -qx '\''use multi/handler; set PAYLOAD generic/shell_reverse_tcp; set LHOST 1.1.1.1; set LPORT 5555'\'''" >> "$ZSHRC_FILE"
echo "alias revshells='firefox https://www.revshells.com/ &'" >> "$ZSHRC_FILE"
echo "alias psrevshell='python /home/kali/Desktop/Tools/Windows/Powershell-Base64-Reverse-Shell-Generator/PowerShellReverseShellGen.py'" >> "$ZSHRC_FILE"

echo ""
echo "${ORANGE}[*]${NC}The following ${GREEN}aliases${NC} are added to ${GREEN}$ZSHRC_FILE:"
echo "${ORANGE}[*]${GREEN}pyserv${NC} (starts a python server on port 80)"
echo "${ORANGE}[*]${GREEN}smbserv${NC} (starts impacket-smbserver)"
echo "${ORANGE}[*]${GREEN}load${NC} (xdg-open)"
echo "${ORANGE}[*]${GREEN}multi${NC} (starts msf multi/handler)"
echo "${ORANGE}[*]${GREEN}revshells${NC} (starts firefox and navigates to revshells.com)"
echo "${ORANGE}[*]${GREEN}psrevshell${NC} (Generates a base64 encoded PowerShell reverse shell)"

echo ""
# Update the system
echo "${ORANGE}[*]${NC}Running ${GREEN}apt update"
sudo apt update -qq > /dev/null 2>&1
echo "${ORANGE}[*]${NC}Running ${GREEN}apt upgrade"
sudo apt upgrade -y -qq > /dev/null 2>&1
echo "${ORANGE}[*]${NC}Installing dependencies"
echo "${ORANGE}[*]${NC}This may take some time..."
sudo apt install golang-go enum4linux-ng autorecon seclists curl dnsrecon enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf -y -qq > /dev/null 2>&1
echo ""
# Check if the Desktop directory exists
if [ ! -d "$DESKTOP_DIR" ]; then
  echo "${ORANGE}[*]${NC}The Desktop directory ${RED}does not exist${NC}. Creating ${ORANGE}Desktop${NC} directory."
  mkdir -p "$DESKTOP_DIR"
fi
# Check if the Tools directory already exists
if [ -d "$TOOLS_DIR" ]; then
  echo "${ORANGE}[*]${NC}The ${ORANGE}Tools${NC} directory already exists."
else
  # Create the Tools directory
  mkdir "$TOOLS_DIR"
  echo "${ORANGE}[*]${NC}Creating directory ${ORANGE}Tools${NC} at ${GREEN}$TOOLS_DIR"
fi

###MAIN DIRECTORY###
# clone laZagne into the Tools directory
cd "$TOOLS_DIR"
git clone --quiet https://github.com/AlessandroZ/LaZagne
echo "${ORANGE}[*]${NC}Cloned LaZagne into ${GREEN}$TOOLS_DIR"
echo ""
####LINUX TOOLS###
# Create the subdirectories if they do not exist
if [ ! -d "$LINUX_DIR" ]; then
  mkdir "$LINUX_DIR"
  echo "${ORANGE}[*]${ORANGE}Linux${NC} directory created at ${GREEN}$LINUX_DIR"
fi
# Download files in the Linux directory
cd "$LINUX_DIR"
echo "${ORANGE}[*]${NC}Installing Linux tools"
wget -q https://github.com/peass-ng/PEASS-ng/releases/download/20240602-829055f0/linpeas.sh
echo "${ORANGE}[*]${NC}Downloaded linpeas.sh into ${GREEN}$LINUX_DIR"
echo ""
###WINDOWS TOOLS###
if [ ! -d "$WINDOWS_DIR" ]; then
  mkdir "$WINDOWS_DIR"
  echo "${ORANGE}[*]${NC}Creating ${ORANGE}Windows${NC} directory at ${GREEN}$WINDOWS_DIR"
fi
cd "$WINDOWS_DIR"
echo "${ORANGE}[*]${NC}Installing Windows tools"
wget -q https://download.sysinternals.com/files/PSTools.zip
echo "${ORANGE}[*]${NC}Downloaded PSTools.zip into ${GREEN}$WINDOWS_DIR"
mkdir PStools
unzip -q PSTools.zip -d PStools 
echo "${ORANGE}[*]${NC}Unzipped PSTools.zip into ${GREEN}$WINDOWS_DIR/PStools"
rm PSTools.zip
echo "${ORANGE}[*]${RED}Removed${NC} PSTools.zip from ${GREEN}$WINDOWS_DIR"
git clone --quiet https://github.com/TheHoffa/Powershell-Base64-Reverse-Shell-Generator
echo "${ORANGE}[*]${NC}Cloned Powershell-Base64-Reverse-Shell-Generator into ${GREEN}$WINDOWS_DIR"
echo "${ORANGE}[*]${NC}Created folder winPEAS at ${GREEN}$WINDOWS_DIR/winPEAS"
mkdir winPEAS
cd winPEAS
wget -q https://github.com/peass-ng/PEASS-ng/releases/download/20240602-829055f0/winPEAS.bat
echo "${ORANGE}[*]${NC}Downloaded winPEAS.bat into ${GREEN}$WINDOWS_DIR/winPEAS"
wget -q https://github.com/peass-ng/PEASS-ng/releases/download/20240602-829055f0/winPEASx64.exe
echo "${ORANGE}[*]${NC}Downloaded winPEASx64.exe into ${GREEN}$WINDOWS_DIR/winPEAS"
wget -q https://github.com/peass-ng/PEASS-ng/releases/download/20240602-829055f0/winPEASx86.exe
echo "${ORANGE}[*]${NC}Downloaded winPEASx86.exe into ${GREEN}$WINDOWS_DIR/winPEAS"
echo ""
####TUNNEL TOOLS###
if [ ! -d "$TUNNELING_DIR" ]; then
  mkdir "$TUNNELING_DIR"
  echo "${ORANGE}[*]${NC}Creating ${ORANGE}Tunneling${NC} directory at ${GREEN}$TUNNELING_DIR"
fi
# Change to the Tunneling directory
cd "$TUNNELING_DIR"
echo "${ORANGE}[*]${NC}Installing tunneling tools"
# clone --quiet the ligolo-ng repository if it does not already exist
if [ ! -d "$TUNNELING_DIR/ligolo-ng" ]; then
  git clone --quiet https://github.com/nicocha30/ligolo-ng
  echo "${ORANGE}[*]${NC}Cloned Ligolo-ng into ${GREEN}$TUNNELING_DIR/ligolo-ng"
fi
# Change to the ligolo-ng directory
cd "$TUNNELING_DIR/ligolo-ng"
# Build the project for Linux
echo "${ORANGE}[*]${NC}Building ligolo-ng agent"
go build -o agent cmd/agent/main.go >/dev/null 2>&1
echo "${ORANGE}[*]${NC}Built ligolo-ng agent"
echo "${ORANGE}[*]${NC}Building ligolo-ng proxy"
go build -o proxy cmd/proxy/main.go >/dev/null 2>&1
echo "${ORANGE}[*]${NC}Built ligolo-ng proxy"
# Build the project for Windows
echo "${ORANGE}[*]${NC}Building ligolo-ng agent.exe" 
GOOS=windows go build -o agent.exe cmd/agent/main.go >/dev/null 2>&1
echo "${ORANGE}[*]${NC}Built ligolo-ng agent.exe"
echo "${ORANGE}[*]${NC}Building ligolo-ng proxy.exe"
GOOS=windows go build -o proxy.exe cmd/proxy/main.go >/dev/null 2>&1
echo "${ORANGE}[*]${NC}Built ligolo-ng proxy.exe"
echo "${ORANGE}[*]${NC}Ligolo-ng build completed successfully."
echo ""
cd "$DESKTOP_DIR"
echo "${ORANGE}[*]${NC}Creating directory ${ORANGE}Stand-Alone-1${NC} at ${GREEN}$DESKTOP_DIR"
mkdir "Stand-Alone-1"
echo "${ORANGE}[*]${NC}Creating directory ${ORANGE}Stand-Alone-2${NC} at ${GREEN}$DESKTOP_DIR"
mkdir "Stand-Alone-2"
echo "${ORANGE}[*]${NC}Creating directory ${ORANGE}Stand-Alone-3${NC} at ${GREEN}$DESKTOP_DIR"
mkdir "Stand-Alone-3"
echo "${ORANGE}[*]${NC}Creating directory ${ORANGE}AD-set${NC} at ${GREEN}$DESKTOP_DIR"
mkdir "AD-set"
echo ""
# Countdown function
countdown() {
    for i in {10..1}; do
        echo -n "${ORANGE}[*]${NC} Exam setup ${GREEN}completed${NC} setup will end in ${ORANGE}$i${NC} seconds..."
        sleep 1
        echo -ne "\r\033[K"  # Clear the line
    done
    echo "${ORANGE}[*]${NC} Setup finished."
}

# Execute the countdown function
countdown

# Prompt the user to press Enter
echo -n "${ORANGE}[*]${NC} Press ${ORANGE}Enter${NC} to continue..."
read choice

# Execute commands after countdown
echo "${ORANGE}[*]${NC} Executing ${ORANGE}'exec zsh'${NC} command..."
exec zsh
