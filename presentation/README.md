

# HMT Presentation Template, 2019

Assuming you have [Pandoc](https://pandoc.org) intalled, build an HTML presentation with:

~~~

pandoc -t revealjs presentation.md -s -o presentation.html --metadata pagetitle=presentation

~~~

Open the resulting file, `presentation.html`, in a browser.

To make a copy of the template for your own use:

~~~

cp presentation.md myPresentation.md
pandoc -t revealjs myPresentation.md -s -o myPresentation.html --metadata pagetitle=presentation

~~~

**The HTML files created by this method assume that they are in the present directory, along with the files in the `reveal.js` directory.**
