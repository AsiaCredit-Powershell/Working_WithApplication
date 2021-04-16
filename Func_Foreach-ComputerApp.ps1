function Foreach-ComputerApp {
    param 
    (
        $PCName,
        [Parameter(Mandatory = $true)]
        [ValidateSet(
          'Get-Application', 
          'Remove-Application'
          )]
        $CommandLine
    )
    
    # Формируем сообщения и запрашиваем данные по компам из домена
    $ErrorMessage = "Не должно быть меньше двух ПК в списке. "
    $ComputerNames = (Get-ADComputer -Filter "name -like '*$PCName*'").Name

    # Если компов меньше одного - тогда прерываем процедуру и выводим сообщение 
    if ($PCNames.name.count -le 1) 
    {
        $ComputerNames = $PCNames.Name
        $ErrorMessage + "`n`r" + "$ComputerNames"
        return $ErrorMessage
        break
    }

    else 
    {
        Foreach ($ComputerName in $ComputerNames) 
        {
            if ($Null -ne $FilterApp)
            {
                $Output = $CommandLine -PCName $Computername -FilterApp $FilterApp
            }
                    
            else 
            {
                $Output = $CommandLine -PCName $Computername 
            }
        }
    }
    return $Output
}