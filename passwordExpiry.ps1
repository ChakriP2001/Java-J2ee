# Define the current date for file naming
$date = Get-Date -Format "dd-MM-yyyy" 
#set the report name 
$reportNamePasswordExpiry15days = "Users_PasswordExpiry15daysReport_" + $date + ".csv" 

# Get List of Domains from reference table 
$domainControllers = $inputmap.Domains -split ',' 
#$domainControllers = @("pharmalucence.com") 

# Initialize an array to store the results 
$results = @() 

# Initialize hashtables for each expiry day range with new variable names 
$expiryDictionaries = @{ '0user' = @() '1user' = @() '2user' = @() '3user' = @() '4user' = @() '5user' = @() '6user' = @() '7user' = @() '8user' = @() '9user' = @() '10user' = @() '11user' = @() '12user' = @() '13user' = @() '14user' = @() '15user' = @() } 
 
#initialize new hastables for expiry dates 
$expiryDateDictionaries= @{ '0user' = @() '1user' = @() '2user' = @() '3user' = @() '4user' = @() '5user' = @() '6user' = @() '7user' = @() '8user' = @() '9user' = @() '10user' = @() '11user' = @() '12user' = @() '13user' = @() '14user' = @() '15user' = @() } 

# Loop through each domain controller 
foreach ($dc in $domainControllers) {
    try { 
        # Retrieve the active users from the domain controller with additional properties 
        $users = Get-ADUser -Filter * -Server $dc -credential $concreds1 -Properties PasswordLastSet, Enabled, DisplayName, GivenName, Surname, EmailAddress, AccountExpirationDate | Where-Object { $_.Enabled -eq $true } } 
    catch { 
            # Handle connection errors 
            Write-Output "Unable to Connect to $dc" 
            continue 
        } 
    # Loop through each user and calculate the password age and expiry 
    foreach ($user in $users) { 
     if ($user.PasswordLastSet -and $user.EmailAddress) {
        # Calculate the password age in days 
        $passwordAge = (New-TimeSpan -Start $user.PasswordLastSet -End (Get-Date)).Days 
        $passwordPolicyDays = 60 # Assumes a 60-day password policy 
        
        # Calculate password expiry assuming a typical 60-day policy 
        $expiryDate = $user.PasswordLastSet.AddDays($passwordPolicyDays) 
        $expiryAge = (New-TimeSpan -Start (Get-Date) -End $expiryDate).Days 
        
        # Add user email to the appropriate hashtable based on the expiry age 
        if ($expiryAge -ge 0 -and $expiryAge -le 15) {
             $expiryDictionaries["${expiryAge}user"] += $user.EmailAddress $expiryDateDictionaries["${expiryAge}user"] += $expiryDate.ToString("dd-MM-yyyy") 
            # Store the results in the array 
            $results += [PSCustomObject]@{ 
                UserName = $user.SamAccountName 
                PasswordAge = $passwordAge 
                PasswordExpiryDays = $expiryAge 
                Domain = $dc 
                GivenName = $user.GivenName 
                Surname = $user.Surname 
                EmailAddress = $user.EmailAddress 
                AccountExpirationDate = $expiryDate.ToString("dd-MM-yyyy") 
             }
            }
        }
    }
} 
if ($results) { 
    $csvdatacounts = @($results) 
    } else { 
        $csvdatacounts = @() 
        } 
 $odays = $expiryDictionaries | ConvertTo-Json 
 $expiryDatesJson = $expiryDateDictionaries | ConvertTo-Json 
 # Export the results to CSV if there are any results 
 $outputCsvPathPasswordAge15days = $inputMap.path+$reportNamePasswordExpiry15days 
 #$results | Export-Csv -Path "C:\\Temp\pass\ADUsersPasswordAgewithall.csv" -NoTypeInformation 
# Check if data is empty. 
if ($csvdatacounts.Count -gt 0) { 
    # Prepare JSON-encoded day-by-day email lists 
    $results | Export-Csv -Path $outputCsvPathPasswordAge15days -NoTypeInformation 
    # Prepare the final output 
    Write-Output "Details Saved | $reportNamePasswordExpiry15days | $odays | $expiryDatesJson" 
 } else { 
    Write-Output "No users' password expiry within 15 days report today." } # Export the results to CSV if there are any results 
    $outputCsvPathPasswordAge30days = $inputMap.path+$reportNamePasswordExpiry30days #$results | Export-Csv -Path "C:\\Temp\pass\ADUsersPasswordAgewithall.csv" -NoTypeInformation 
        # Check if data is empty. 
        if ($csvdatacounts.Count -gt 0) { 
            # Prepare JSON-encoded day-by-day email lists 
            } else { 
                Write-Output "No users' password expiry within 15 days report today." 
                }