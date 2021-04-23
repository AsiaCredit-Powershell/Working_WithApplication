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
            Invoke-Command -ComputerName $PC -ScriptBlock { 
        
                # Беру все установленные приложения и ищу в них нужное, записываю в переменную ее имя 
                $GetFilterProgramm = Get-WmiObject -Class Win32_Product -Filter "name -like '*$Using:FilterApp*'"
                $AppNames = $GetFilterProgramm.name 
        
                # Если нет объекта - тогда выводим сообщение 
                if ($null -eq $GetFilterProgramm) 
                {
                    $Message = $AppNames + "удален или не обнаружен "
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
                        $Message = $AppNames + "удален "
                    }
            
                    else 
                    {
                        $Message = $AppNames + " - удалить его не вышло"
                    }
                } 
                    
                # Заполняем массив для дальнейшего удобства работы 
                $Array = [pscustomobject]@{ComputerName = "$env:COMPUTERNAME";Message = "$Message"}
                $Array
            } 
        }
    }
    return $Array
}
