
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
            $Message = "ПК найти не удалось. Измени параметры поиска нежели $PCName"
        }
            
        else 
        {
            Invoke-Command -ComputerName $PCs -ScriptBlock { 
        
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
                $Array
            } 
        }
        return $Array
    }
}