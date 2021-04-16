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
                $Output = & $CommandLine -PCName $Computername -FilterApp $FilterApp
            }
                    
            else 
            {
                $Output = & $CommandLine -PCName $Computername 
            }
        }
    }
    return $Output
}

Function Get-Application {
    param 
    (
        $PCName,
        $FilterApp
    )

    # Получил список нужных машин
    $PCs = (Get-ADComputer -Filter "name -like '*$PCName*'").name

    # Если ПК больше одного - то вызываем процедуру цикла для командлета foreach-computerapp
    if ($PCs.Count -gt 1)         
    {
        $Array = Foreach-ComputerApp -CommandLine Get-Application -PCName $PCName
    }

    #Если один ПК - тогда подулючаемся к нему.
    else 
    {
            # Если нет данных - тогда ошибка 
        if ($null -eq $PCs)
        {
            $Message = "ПК найти не удалось. Измени параметры поиска нежели " + $PCName
        }
            
        else 
        {
            Invoke-Command -ComputerName $PC -ScriptBlock { 
        
                # Беру все установленные приложения и ищу в них нужное, записываю в переменную ее имя 
                $GetFilterProgramm = Get-WmiObject -Class Win32_Product -Filter "name -like '*$Using:FilterApp*'"
                $AppNames = $GetFilterProgramm.name 
        
                # Если нет объекта - тогда выводим сообщение 
                if ($null -eq $AppNames) 
                {
                    $Message = $FilterApp + "`r`n" +  "Отсутствует на ПК "
                    Break
                }

                # Если объект есть - тогда выводим в сообщение
                else 
                {
                    $Message = foreach ($AppName in $AppNames) 
                    {
                        $ForeachMessage = "Найдены следующие программы: " + $AppName
                        $ForeachMessage
                    }
                } 
  
                # Заполняем массив для дальнейшего удобства работы 
                $Array = [pscustomobject]@{ComputerName = "$env:COMPUTERNAME";Message = "$Message"}
            } 
        }
        return $Array
    }
}

Function Remove-Application {
    param 
    (
        $PCName,
        $FilterApp
    )

    # Получил список нужных машин
    $PCs = (Get-ADComputer -Filter "name -like '*$PCName*'").name

    # Если ПК больше одного - то вызываем процедуру цикла
    if ($PCs.Count -gt 1)         
    {
        $Array = Foreach-ComputerApp -CommandLine Remove-Application -PCName $PCName
    }

    #Если один ПК - тогда подулючаемся к нему.
    else 
    {
        # Если нет данных - тогда ошибка 
        if ($null -eq $PCs)
        {
            $Message = "ПК найти не удалось. Измени параметры поиска нежели $PCName"
            Break
        }
                
        else 
        {
            Invoke-Command -ComputerName $PC -ScriptBlock 
            { 
        
                # Беру все установленные приложения и ищу в них нужное, записываю в переменную ее имя 
                $GetFilterProgramm = Get-WmiObject -Class Win32_Product -Filter "name -like '*$Using:FilterApp*'"
                $AppNames = $GetFilterProgramm.name 
        
                # Если нет объекта - тогда выводим сообщение 
                if ($null -eq $GetFilterProgramm) 
                {
                    $Message = "$AppNames" + " удален или не обнаружен"
                }

                # Если объект есть - тогда удаляем
                else 
                {
                    "Произвожу удаление на машине " + $env:COMPUTERNAME

                    foreach ($AppName in $AppNames) 
                    {
                        $GetFilterProgramm.uninstall()
                    }

                    $GetFilterProgrammVerify = Get-WmiObject -Class Win32_Product -Filter "name -like '*$Using:FilterApp*'"
                    $AppNames = $GetFilterProgrammVerify.name 
            
                    # Осуществляем проверку удаления 
                    if ($null -eq $GetFilterProgramm) 
                    {
                        $Message = "удален " + $AppNames
                    }
            
                    else 
                    {
                        $Message = $AppNames + "присутствует - удалить его не вышло"
                    }
                } 
                    
                # Заполняем массив для дальнейшего удобства работы 
                $Array = [pscustomobject]@{ComputerName = "$env:COMPUTERNAME";Message = "$Message"}
            } 
        }
    }
    return $Array
}

