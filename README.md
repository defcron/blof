# blch and blof archive utilities

## create and extract .blch and .blof files

- .blof - binary linear object file

- .blch - binary linear object file with checksum header

---

**.blof** files are just ascii binary representation (0 and 1 characters) of whatever files or folders you decide to archive or whatever contents that you pass in on stdin to the `blof` utility when calling it with no arguments, but first being added into a `.tar` archive and then the .tar being compressed with the `gzip -9` command.
The binary characters (again, just ascii 0 and 1) are all contiguous with no spaces anywhere and there's no newline at the end of the string of characters. `.blof` files are the foundation for `.blch` files, which in turn are the better, more complete format to be preferred to be used in most cases.

**.blch** is the archive file type that's better to use than `.blof` files, for most purposes. `.blch` files (pronounced "BLCH", "BUL-CH", or "belch" if you prefer (eww!)) are just `.blof` files with a header at the beginning and then a single whitespace character, followed by the contents of a .blof file. The header is the output of the command `sha256sum -z --tag` being used on the ascii 0 and 1 characters which appear after the header in the `.blch` file, but with some post-processing to remove all the whitespace from the output of that sha checksum command and to remove the null byte it would otherwise introduce into the output string.

That's the format for **.blch** and their foundational **.blof** file types. This git repository is the reference implementation of the official tooling for creating and working with `blof` and `blch` files, and it currently offers a `bash` implementation using standard tools available on most or all Linux and other similar kinds of operating systems.

Please file an issue if you find any bugs, and submit pull requests if you want, and I'll address them time-permitting.

These are very minimal and lightweight file format specifications, and I hope you find them as useful as I do. I had a bit of help from Tim, my custom GPT-4o-based ChatGPT model on this project, but mostly just a consult, and I did most of it by hand like in the old days. :)

Enjoy!

~defcron
