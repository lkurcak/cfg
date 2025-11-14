let merged_branches = git branch -vv | lines | str trim | where $it =~ ': gone' | each { |line|
    let cleaned = ($line | str replace -r '^\*\s*' "")
    let branch = ($cleaned | split column " " | get column1)
    $branch
} | flatten

$merged_branches | each { |branch| git branch -d $branch }
