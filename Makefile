COFFEE_FILES=${shell find src -name "*.coffee"}
JS_FILES=$(COFFEE_FILES:.coffee=.js)
BIN=${shell npm bin}

DOC_MD_FILES=${shell find doc -name "*.md"}
DOC_HTML_FILES=$(DOC_MD_FILES:.md=.html)


all: lib doc test

# compiles coffee-script
%.js : %.coffee node_modules
	${BIN}/coffee -c $<

# compile less
%.css : %.less node_modules
	${BIN}/lessc $< $@

# minifies js
%.min.js : %.js node_modules
	${BIN}/uglifyjs -o $@ $< 

# compiles html files using markitup
%.html: %.md %.jade doc/layout.jade node_modules 
	${BIN}/markitup -t $(word 2,$^) -o doc/ $<
# Fallback to default if the specific template does not exists.
%.html: %.md doc/default.jade doc/layout.jade node_modules 
	${BIN}/markitup -t $(word 2,$^) -o doc/ $<



node_modules: package.json
	npm install

clean:
	rm -f ${JS_FILES}
	rm -fr node_modules
	rm -f doc/*.html
	rm -f examples/assets/*.js
	rm -f examples/assets/*.css

doc/assets/potato.min.js: potato.js
	cp potato.min.js doc/assets/potato.min.js

doc: doc/assets/markstrap.js doc/assets/markstrap.css doc/assets/potato.min.js doc/assets/examples.js ${DOC_HTML_FILES}

# build all lib files
lib: potato.js potato.min.js potato-browserify.js potato-browserify-min.js

potato.js: ${JS_FILES} node_modules
	${BIN}/browserify -e src/entry-point-browserify.js --outfile ./potato.js

potato-browserify.js: ${JS_FILES} node_modules
	${BIN}/browserify src/potato.js --outfile ./potato-browserify.js

# launch tests
test: ${JS_FILES} node_modules
	@npm test

