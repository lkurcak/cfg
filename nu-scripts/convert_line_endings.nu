# Convert all text files from Windows (CRLF) to Linux (LF) line endings
# Usage: nu convert_line_endings.nu <directory>

def main [directory: path] {
    # Common text file extensions
    let text_extensions = [
        txt py js java c cpp h hpp cs php rb go rs sh bash zsh
        html htm xml css scss sass less json yaml yml toml ini cfg conf
        md markdown rst tex sql r m pl lua vim el clj scala kt
        swift dart ts tsx jsx vue svelte
    ]
    
    print $"Scanning directory: ($directory)"
    print ""
    
    # Find all files recursively
    let files = (glob $"($directory)/**/*" | where { |f| ($f | path type) == "file" })
    
    mut converted = 0
    mut skipped = 0
    
    for file in $files {
        let ext = ($file | path parse | get extension)
        
        # Check if it's a text file
        if ($ext in $text_extensions) {
            # Read file as raw binary
            let content = (open --raw $file | into binary)
            
            # Check if file contains CRLF (0x0D 0x0A)
            let has_crlf = ($content | bytes index-of 0x[0D 0A]) != -1
            
            if $has_crlf {
                # Read as raw string, replace CRLF with LF, and save
                let text = (open --raw $file)
                let converted_text = ($text | str replace --all "\r\n" "\n")
                $converted_text | save --raw --force $file
                
                print $"✓ Converted: ($file)"
                $converted += 1
            } else {
                $skipped += 1
            }
        }
    }
    
    print ""
    print "Summary:"
    print $"  Files converted: ($converted)"
    print $"  Files skipped \(no CRLF\): ($skipped)"
}
