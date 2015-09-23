index.html: index.md
	R -e "markdown::markdownToHTML('$<', '$@')"
