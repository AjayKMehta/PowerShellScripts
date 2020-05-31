function Test-Integer($x) {
    try{
        return ([int]$x -eq $x)
    }
    catch{
        return $false
    }
}