The contents of this directory is used to customize the output of Pandoc, the software used to produce DOCX exports of casebooks.


## Reference Document

`reference.docx` is a zip of the contents of the `reference_docx/` directory and is responsible for mapping our "[Custom Styles](https://pandoc.org/MANUAL.html#custom-styles)" by name to a set of styles and visual properties. To use a web-based analogy: `reference_docx/` is akin to `scss`; `reference.docx` is akin to the compiled css to be used for rendering; the "Custom Styles" are akin to HTML classes that can be used as selectors in the scss.

It was [originally generated by pandoc](https://pandoc.org/MANUAL.html#option--reference-doc), and then was altered to include H2O's style definitions.

Generally, to modify:

```
$ cd docker/pandoc-lambda/reference_docx/src/word/
$ zip -r ../reference.docx *
$ # [now open reference.docx to see if your broke it.]
```
### Customization Workflow
Re-stylers will find the bits in `reference_docx/src/word/styles.xml` most interesting. It's moderately well-commented, but a solid understanding of OOXML styles and their MS implementations will save you time and frustration, even with modest changes. Units of measurement, value labels, and the relationship between styles and are quite different in the GUI than under the hood. 

No reliable workflow affords immediate reliable visual feedback *and* a produces a styles.xml file that works well as a data store and documentation for anyone who'd like to build on your work. Clients will will strip comments and add in a bunch of client-specific cruft, at a minimum. Trying to replace the reference files with ones saved in a client will probably produce a broken document because the relationships will break. For heavy modifications, your best bet is likely working in word to ensure you've got a cohesive design, saving and unzipping your docx, and then copying your modified styles over, by hand, ensuring the relationships (basedOn, links, etc.) are sound. Syncing regularly and 
testing will save time— the earlier you find out your changes might not render as expected, the better.


## Table of Contents

Pandoc includes the ability to automatically add a Table of Contents to a DOCX using Word's own Automatic Table of Contents feature, but at the time of writing, that feature is insufficient for our needs: it can only assemble a list of the Headings in the document and map those Headings to page numbers.

Instead, we inject a small amount of specialized HTML while preparing a casebook and run a [custom lua filter](https://pandoc.org/lua-filters.html), `table_of_contents.lua`, that finds that HTML and uses it to manually build the XML necessary both for our custom Table of Contents and for the bookmarks it points to.