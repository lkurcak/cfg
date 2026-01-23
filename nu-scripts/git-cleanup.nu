#!/usr/bin/env nu

# Git branch cleanup - removes local branches whose remote tracking branch is gone
# Handles squash-merged branches correctly by using `git cherry` to detect equivalent commits

def main [
    --base (-b): string = "main"    # Base branch to compare against
    --force (-f)                    # Auto force-delete branches with unique commits (dangerous!)
    --dry-run (-n)                  # Show what would be done without doing it
    --yes (-y)                      # Skip confirmation prompts, delete all safe branches
] {
    # Ensure we're in a git repo
    if (do { git rev-parse --git-dir } | complete).exit_code != 0 {
        print -e "Error: not in a git repository"
        exit 1
    }

    # Fetch latest remote state
    print "Fetching remote state..."
    git fetch --prune

    # Get branches with gone upstreams
    let stale = (get-stale-branches)

    if ($stale | is-empty) {
        print "✓ No stale branches found"
        return
    }

    print $"Found ($stale | length) stale branch\(es\):\n"

    # Analyze each branch
    let analyzed = ($stale | each {|branch|
        let unique_commits = (count-unique-commits $base $branch)
        {
            branch: $branch
            unique_commits: $unique_commits
            safe: ($unique_commits == 0)
        }
    })

    # Display summary table
    $analyzed | select branch unique_commits safe | print

    print ""

    let safe_branches = ($analyzed | where safe)
    let unsafe_branches = ($analyzed | where not safe)

    # Handle safe branches (no unique commits)
    if not ($safe_branches | is-empty) {
        print $"(ansi green)Safe to delete(ansi reset) \(squash-merged\): ($safe_branches | length)"

        if $dry_run {
            print "  [dry-run] Would delete:"
            $safe_branches | each { print $"    ($in.branch)" }
        } else if $yes or (confirm "Delete these branches?") {
            $safe_branches | each {|row|
                # Use force delete (-D) because git's -d doesn't understand squash merges
                # We've already verified safety via git cherry
                delete-branch $row.branch true
            }
        }
    }

    # Handle unsafe branches (have unique commits)
    if not ($unsafe_branches | is-empty) {
        print $"\n(ansi yellow)Have unique commits(ansi reset): ($unsafe_branches | length)"

        if $force {
            print "(ansi red)--force specified, deleting anyway!(ansi reset)"
            if not $dry_run {
                $unsafe_branches | each {|row|
                    delete-branch $row.branch true
                }
            }
        } else if not $dry_run {
            # Interactive mode for unsafe branches
            $unsafe_branches | each {|row|
                handle-unsafe-branch $row.branch $row.unique_commits
            }
        } else {
            print "  [dry-run] These branches have unique commits:"
            $unsafe_branches | each { print $"    ($in.branch) - ($in.unique_commits) unique commit\(s\)" }
        }
    }

    print "\n✓ Done"
}

# Get local branches whose upstream is marked as "gone"
def get-stale-branches [] {
    git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads
    | lines
    | where ($it | str contains "[gone]")
    | each { $in | str replace " [gone]" "" | str trim }
}

# Count commits in branch that aren't in base (handles squash merges)
def count-unique-commits [base: string, branch: string] {
    # Check if base branch exists
    let base_exists = (do { git rev-parse --verify $base } | complete)
    if $base_exists.exit_code != 0 {
        print -e $"  (ansi red)Error: base branch '($base)' not found(ansi reset)"
        return (-1)
    }

    # Check if there's a merge base (branches must share history)
    let merge_base = (do { git merge-base $base $branch } | complete)
    if $merge_base.exit_code != 0 {
        print -e $"  (ansi yellow)Warning: no common ancestor between ($base) and ($branch)(ansi reset)"
        return (-1)
    }

    let result = (do { git cherry $base $branch } | complete)
    if $result.exit_code != 0 { 
        print -e $"  (ansi red)git cherry failed for ($branch): ($result.stderr | str trim)(ansi reset)"
        return (-1) 
    }

    $result.stdout
    | lines
    | where ($it | str starts-with "+")
    | length
}

# Delete a branch
def delete-branch [branch: string, force: bool] {
    let flag = if $force { "-D" } else { "-d" }
    let result = (do { git branch $flag $branch } | complete)

    if $result.exit_code == 0 {
        let action = if $force { "Force-deleted" } else { "Deleted" }
        print $"  (ansi green)✓(ansi reset) ($action) ($branch)"
    } else {
        print $"  (ansi red)✗(ansi reset) Failed to delete ($branch): ($result.stderr | str trim)"
    }
}

# Interactive handler for branches with unique commits
def handle-unsafe-branch [branch: string, commit_count: int] {
    print $"\n(ansi yellow)($branch)(ansi reset) has ($commit_count) unique commit\(s\)"

    # Show the commits
    print "  Commits:"
    git log --oneline $"main..($branch)" | lines | first 5 | each { print $"    ($in)" }

    let choice = (input "  [s]kip, [a]rchive, [f]orce-delete, [v]iew diff? (s/a/f/v): " | str trim | str downcase)

    match $choice {
        "a" => {
            let archive_name = $"archive/($branch)"
            let result = (do { git branch -m $branch $archive_name } | complete)
            if $result.exit_code == 0 {
                print $"  (ansi green)✓(ansi reset) Archived as ($archive_name)"
            } else {
                print $"  (ansi red)✗(ansi reset) Archive failed"
            }
        }
        "f" => { delete-branch $branch true }
        "v" => {
            git diff $"main...($branch)" --stat
            handle-unsafe-branch $branch $commit_count  # recurse for another choice
        }
        _ => { print "  Skipped" }
    }
}

# Simple yes/no confirmation
def confirm [prompt: string] {
    let response = (input $"($prompt) \(y/N\): " | str trim | str downcase)
    $response == "y" or $response == "yes"
}
