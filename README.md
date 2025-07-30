# Windows DNS Changer GUI

A simple, user-friendly graphical application for quickly changing your DNS settings on Windows 10 and 11.

---

## **About The Project**
This tool provides a convenient graphical user interface (GUI) to switch between popular public DNS providers or set your own custom DNS servers. It eliminates the need to navigate through multiple Windows settings menus. The application is built with PowerShell and packaged as a standalone `.exe` file.

---

## **Features**
- **Graphical Interface:** Easy-to-use buttons and dropdowns.  
- **Auto-Detection:** Automatically finds and lists your active network adapters (e.g., "Wi-Fi", "Ethernet").  
- **Popular Presets:** Includes presets for Cloudflare, Google, Quad9, and OpenDNS.  
- **Custom DNS:** Option to set any primary and secondary DNS server you want.  
- **Revert to Default:** Easily switch back to your default (DHCP-assigned) DNS settings.  
- **Standalone:** Runs as a single `.exe` file with no external dependencies or installation required.  
- **Self-Elevating:** Automatically prompts for Administrator permission, which is required to change network settings.

---

## **How to Use (for End-Users)**
1. Go to the **Releases** page of this repository.  
2. Download the latest **DNS-Changer.exe** file.  
3. Double-click the `.exe` file to run it.  
4. Windows will show a **User Account Control (UAC)** prompt. Click **Yes** to allow the app to run with administrator privileges.  
5. Select your network adapter, choose a DNS option, and click **"Apply Settings"**.

---

## **How to Compile from Source (for Developers)**

If you want to modify the script or build the executable yourself, follow these steps:

### **Prerequisites**
- Windows 10 or Windows 11  
- PowerShell 5.1 or later  

### **Compilation Steps**
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. **Open PowerShell as Administrator.**

3. **Set the Execution Policy:**
   If you haven't done this before, you need to allow scripts to run:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Force
   ```

4. **Install the ps2exe module:**
   This module bundles the PowerShell script into an executable:
   ```powershell
   Install-Module -Name ps2exe -Force
   ```

5. **Compile the script:**
   Run the following command in PowerShell from the project's root directory. This will create the **DNS Changer.exe** file:
   ```powershell
   ps2exe -inputFile 'DNS-Changer-GUI.ps1' -outputFile 'DNS Changer.exe' -noConsole -iconFile 'icon.ico'
   ```
   - `-noConsole`: Prevents the black console window from appearing.  
   - `-iconFile 'icon.ico'`: Embeds the application icon.

---

## **License**
This project is licensed under the **MIT License** - see the [LICENSE.md](LICENSE.md) file for details.
