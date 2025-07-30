<#
.SYNOPSIS
    A graphical user interface (GUI) application to change DNS settings on Windows 11/10.

.DESCRIPTION
    This PowerShell script launches a Windows Form that allows users to easily change their DNS settings.
    It automatically detects active network adapters and provides a list of popular DNS providers.
    The script now includes a self-elevation mechanism to ensure it runs as Administrator.
    All status messages and errors are logged directly within the GUI's status box.

.NOTES
    Author: almaadin
    Version: 1.0.0
    Changes:
    - Fixed the "Cannot find an overload for 'Invoke'" crash by removing the unnecessary Invoke method from the
      Update-Status function. This resolves the failure to detect network adapters.
    - The new elevation logic re-launches the .exe itself instead of calling powershell.exe.
#>

# --- Self-Elevation: Check for Administrator privileges and re-launch if necessary ---
if (-not ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        # Get the path of the currently running process (works for both .ps1 and .exe)
        $processPath = (Get-Process -Id $pid).Path
        
        # Re-launch the script/exe with admin rights and exit the current non-admin process
        Start-Process -FilePath $processPath -Verb RunAs
        exit
    }
    catch {
        # If re-launching fails, show an error message box
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Failed to restart with Administrator privileges. Please right-click the file and select 'Run as administrator'.`n`nError: $($_.Exception.Message)", "Elevation Failed", "OK", "Error")
        exit
    }
}


# --- Master Error Handler: Catches any script-terminating errors ---
try {
    # --- Load necessary .NET assemblies for the GUI ---
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # --- Build the Main Form ---
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Windows DNS Changer"
    $form.Size = New-Object System.Drawing.Size(420, 500)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = 'FixedSingle'
    $form.MaximizeBox = $false
    $form.Icon = [System.Drawing.SystemIcons]::Application


    # --- Font Settings ---
    $font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Font = $font

    # --- Status Bar at the bottom ---
    $statusBar = New-Object System.Windows.Forms.RichTextBox
    $statusBar.Location = New-Object System.Drawing.Point(10, 380)
    $statusBar.Size = New-Object System.Drawing.Size(380, 65) # Increased height for more log space
    $statusBar.ReadOnly = $true
    $statusBar.BackColor = "#f0f0f0"
    $statusBar.BorderStyle = "FixedSingle"
    $form.Controls.Add($statusBar)

    # --- Function to update the status bar with color ---
    function Update-Status ($message, $color) {
        # FIX: Removed the unnecessary $form.Invoke wrapper which was causing the crash.
        $statusBar.SelectionStart = $statusBar.TextLength
        $statusBar.SelectionLength = 0
        $statusBar.SelectionColor = [System.Drawing.Color]::$color
        $statusBar.AppendText("$(Get-Date -Format 'HH:mm:ss') - $message`n")
        $statusBar.ScrollToCaret()
    }

    # --- Network Adapter Selection ---
    $labelAdapters = New-Object System.Windows.Forms.Label
    $labelAdapters.Text = "1. Select Network Adapter:"
    $labelAdapters.Location = New-Object System.Drawing.Point(10, 15)
    $labelAdapters.Size = New-Object System.Drawing.Size(380, 20)
    $form.Controls.Add($labelAdapters)

    $comboAdapters = New-Object System.Windows.Forms.ComboBox
    $comboAdapters.Location = New-Object System.Drawing.Point(10, 40)
    $comboAdapters.Size = New-Object System.Drawing.Size(380, 25)
    $comboAdapters.DropDownStyle = "DropDownList" # Prevents user from typing
    $form.Controls.Add($comboAdapters)

    # --- DNS Provider Selection ---
    $groupDns = New-Object System.Windows.Forms.GroupBox
    $groupDns.Text = "2. Choose DNS Provider"
    $groupDns.Location = New-Object System.Drawing.Point(10, 85)
    $groupDns.Size = New-Object System.Drawing.Size(380, 245)
    $form.Controls.Add($groupDns)

    # Create Radio Buttons for each DNS option
    $radioAutomatic = New-Object System.Windows.Forms.RadioButton
    $radioAutomatic.Text = "Automatic (DHCP)"
    $radioAutomatic.Location = New-Object System.Drawing.Point(15, 25)
    $radioAutomatic.Size = New-Object System.Drawing.Size(350, 20)
    $radioAutomatic.Checked = $true
    $groupDns.Controls.Add($radioAutomatic)

    $radioCloudflare = New-Object System.Windows.Forms.RadioButton
    $radioCloudflare.Text = "Cloudflare (1.1.1.1, 1.0.0.1)"
    $radioCloudflare.Location = New-Object System.Drawing.Point(15, 55)
    $radioCloudflare.Size = New-Object System.Drawing.Size(350, 20)
    $groupDns.Controls.Add($radioCloudflare)

    $radioGoogle = New-Object System.Windows.Forms.RadioButton
    $radioGoogle.Text = "Google (8.8.8.8, 8.8.4.4)"
    $radioGoogle.Location = New-Object System.Drawing.Point(15, 85)
    $radioGoogle.Size = New-Object System.Drawing.Size(350, 20)
    $groupDns.Controls.Add($radioGoogle)

    $radioQuad9 = New-Object System.Windows.Forms.RadioButton
    $radioQuad9.Text = "Quad9 (9.9.9.9, 149.112.112.112)"
    $radioQuad9.Location = New-Object System.Drawing.Point(15, 115)
    $radioQuad9.Size = New-Object System.Drawing.Size(350, 20)
    $groupDns.Controls.Add($radioQuad9)

    $radioOpenDns = New-Object System.Windows.Forms.RadioButton
    $radioOpenDns.Text = "OpenDNS (208.67.222.222, 208.67.220.220)"
    $radioOpenDns.Location = New-Object System.Drawing.Point(15, 145)
    $radioOpenDns.Size = New-Object System.Drawing.Size(350, 20)
    $groupDns.Controls.Add($radioOpenDns)

    $radioCustom = New-Object System.Windows.Forms.RadioButton
    $radioCustom.Text = "Custom:"
    $radioCustom.Location = New-Object System.Drawing.Point(15, 175)
    $radioCustom.Size = New-Object System.Drawing.Size(80, 20)
    $groupDns.Controls.Add($radioCustom)

    $textCustom1 = New-Object System.Windows.Forms.TextBox
    $textCustom1.Location = New-Object System.Drawing.Point(100, 173)
    $textCustom1.Size = New-Object System.Drawing.Size(120, 20)
    $textCustom1.Enabled = $false
    $groupDns.Controls.Add($textCustom1)

    $textCustom2 = New-Object System.Windows.Forms.TextBox
    $textCustom2.Location = New-Object System.Drawing.Point(230, 173)
    $textCustom2.Size = New-Object System.Drawing.Size(120, 20)
    $textCustom2.Enabled = $false
    $groupDns.Controls.Add($textCustom2)

    # Enable/disable custom text boxes when "Custom" radio is checked
    $radioCustom.Add_CheckedChanged({
        $textCustom1.Enabled = $this.Checked
        $textCustom2.Enabled = $this.Checked
    })

    # --- Apply Button ---
    $buttonApply = New-Object System.Windows.Forms.Button
    $buttonApply.Text = "Apply Settings"
    $buttonApply.Location = New-Object System.Drawing.Point(10, 340)
    $buttonApply.Size = New-Object System.Drawing.Size(185, 30)
    $form.Controls.Add($buttonApply)

    # --- Close Button ---
    $buttonClose = New-Object System.Windows.Forms.Button
    $buttonClose.Text = "Close"
    $buttonClose.Location = New-Object System.Drawing.Point(205, 340)
    $buttonClose.Size = New-Object System.Drawing.Size(185, 30)
    $form.Controls.Add($buttonClose)
    $buttonClose.Add_Click({ $form.Close() })

    # --- Populate Adapters on Form Load ---
    $form.Add_Load({
        Update-Status "Welcome! Searching for network adapters..." "Black"
        try {
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
            if ($null -ne $adapters) {
                foreach ($adapter in $adapters) {
                    [void]$comboAdapters.Items.Add($adapter.Name)
                }
                $comboAdapters.Tag = $adapters
                $comboAdapters.SelectedIndex = 0
                Update-Status "Adapters found. Please make your selection." "Green"
            } else {
                Update-Status "Error: No active network adapters found." "Red"
                $buttonApply.Enabled = $false
            }
        } catch {
            Update-Status "FATAL ERROR: Could not get network adapters." "Red"
            Update-Status "Please ensure you run this application as an Administrator." "Red"
            Update-Status "Error details: $($_.Exception.Message)" "Red"
            $buttonApply.Enabled = $false
        }
    })

    # --- Logic for the "Apply" button ---
    $buttonApply.Add_Click({
        $statusBar.Clear()
        $selectedAdapterName = $comboAdapters.SelectedItem
        if ([string]::IsNullOrEmpty($selectedAdapterName)) {
            Update-Status "Error: Please select a network adapter first." "Red"
            return
        }
        
        $selectedAdapter = $comboAdapters.Tag | Where-Object { $_.Name -eq $selectedAdapterName }

        $dnsServers = $null
        $dnsProviderName = ""

        if ($radioAutomatic.Checked) { $dnsProviderName = "Automatic (DHCP)" }
        elseif ($radioCloudflare.Checked) { $dnsServers = "1.1.1.1", "1.0.0.1"; $dnsProviderName = "Cloudflare" }
        elseif ($radioGoogle.Checked) { $dnsServers = "8.8.8.8", "8.8.4.4"; $dnsProviderName = "Google" }
        elseif ($radioQuad9.Checked) { $dnsServers = "9.9.9.9", "149.112.112.112"; $dnsProviderName = "Quad9" }
        elseif ($radioOpenDns.Checked) { $dnsServers = "208.67.222.222", "208.67.220.220"; $dnsProviderName = "OpenDNS" }
        elseif ($radioCustom.Checked) {
            $dnsProviderName = "Custom"
            $dnsServers = @($textCustom1.Text, $textCustom2.Text) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            if ($dnsServers.Count -eq 0) {
                Update-Status "Error: Please enter at least one custom DNS server IP." "Red"
                return
            }
        }

        try {
            Update-Status "Applying settings for '$($selectedAdapter.Name)'..." "Black"
            $buttonApply.Enabled = $false # Disable button during operation
            
            if ($dnsProviderName -eq "Automatic (DHCP)") {
                Set-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ResetServerAddresses
                Update-Status "Successfully set DNS to Automatic (DHCP)." "Green"
            } else {
                Set-DnsClientServerAddress -InterfaceIndex $selectedAdapter.InterfaceIndex -ServerAddresses ($dnsServers)
                Update-Status "Successfully set DNS to: $($dnsServers -join ', ')" "Green"
            }
            
            Update-Status "Clearing DNS cache..." "Gray"
            Clear-DnsClientCache
            Update-Status "DNS cache cleared. Operation complete." "Gray"
        } catch {
            Update-Status "Error applying settings: $($_.Exception.Message)" "Red"
        } finally {
            $buttonApply.Enabled = $true # Re-enable button
        }
    })

    # --- Show the form ---
    [void]$form.ShowDialog()

}
catch {
    # --- This block runs ONLY if a fatal error occurs before the form can be displayed ---
    Add-Type -AssemblyName System.Windows.Forms
    $errorMessage = $_.Exception.ToString()
    $errorTitle = "Fatal Script Error"
    [System.Windows.Forms.MessageBox]::Show($errorMessage, $errorTitle, 'OK', 'Error')
}
