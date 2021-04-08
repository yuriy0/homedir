param (
    [Parameter()]
    [ScriptBlock]
    $StripPaths = { param($_) echo $_ },

    [Parameter(Position=0, ValueFromRemainingArguments)]
    [string[]]
    $args
)

function Strip-FirstTwoLines($str)
{
    $lines = $str -split '\r?\n'
    $StripPaths.Invoke($lines[0])
    $StripPaths.Invoke($lines[1])
    $lines[2..($lines.Length - 1)]
}

function Process-P4FileItem ($item)
{
    switch ($item.status)
    {
        # p4 diff2 for some reason includes also files which didn't change
        # Nothing to output for such files
        "identical"
        {
            Break
        }

        # p4 depot type changes have no effect on file diffs
        "types"
        {
            Break
        }

        # Report content changes by regular p4diff2
        "content"
        {
            $p4Diff = p4 diff2 -t -du `
              "$($item.depotFile)#$($item.rev)" `
              "$($item.depotFile2)#$($item.rev2)"
            # Manually insert header for use with git apply
            echo ($StripPaths.Invoke("--- a/$($item.depotFile)"))
            echo ($StripPaths.Invoke("+++ b/$($item.depotFile2)"))
            # Omit header inserted by p4
            $p4Diff[0] = ""
            $p4Diff[1..($p4Diff.Length - 1)]
        }

		# File was removed in source vs. target
        "left only"
        {
            $itemLabel = $item.depotFile
            $itemFile = "$($item.depotFile)#$($item.rev)"
            $diffOut = p4 print -q $itemFile |
              diff.exe -u - /dev/null --label "a/$itemLabel" --label "/dev/null"
            Strip-FirstTwoLines $diffOut
        }

		# File was added in source vs. target
        "right only"
        {
            $itemLabel = $item.depotFile2
            $itemFile = "$($item.depotFile2)#$($item.rev2)"
            $diffOut = p4 print -q $itemFile |
              diff.exe -u /dev/null - --label "/dev/null" --label "b/$itemLabel"
            Strip-FirstTwoLines $diffOut
        }

        default {
			echo "Item: $item"
            throw "Unknown p4 diff2 item status '$($item.status)'"
        }
    }
}

#echo "Strip Prefix: $($StripPaths.ToString())"
#echo "p4 diff2 args: $args"

$filesDiffRaw = p4 -Mj -ztag diff2 -ds $args
#return $filesDiffRaw

if (-not $?)
{
	throw "p4 returned non-zero exit code: $filesDiffRaw"
}

$filesDiffRaw |
  ConvertFrom-Json |
  %{ Process-P4FileItem $_ }
