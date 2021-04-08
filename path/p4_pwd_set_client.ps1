# Sets the current P4 client to the client which matches the current working dir

function NormPath($p)
{
	return [System.IO.Path]::GetFullPath($p).ToLower()
}

$thisHost = p4 info | select-string 'Client host: (.*)' | %{ $_.Matches.Groups[1].Value }
$thisDir = NormPath((pwd).ToString())

function IsSubPath($p)
{
	return $thisDir.StartsWith((NormPath $p), [StringComparison]::InvariantCultureIgnoreCase)
}

$bestClient =
	# All clients owned by me
	p4 -Z tag -Mj clients --me |
	# ... as json objects
	ConvertFrom-Json |
	# ... only those whose host matches or is unset,
	# and whose root dir is inside the current dir 
	?{ ($_.Host -eq "" -or $_.Host -eq $thisHost) -and
		( IsSubPath($_.Root) )
	} |
	# Pick the inner-most client (i.e. whose root path lenght is longest)
	Sort-Object -Top 1 -Descending { $_.Root.Length }

# Check if we found a viable client
if ($bestClient -ne $null)
{
	$clientName = $bestClient.client
	$env:P4CLIENT=$clientName
	Write-Host "Set p4 client to $clientName"
}
else
{
	throw "No p4 clients found which contain the current directory"
}



