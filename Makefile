COFFEE_FILES=${shell find src -name "*.coffee"}
JS_FILES=$(COFFEE_FILES:.coffee=.js)
BIN=${shell npm bin}

all: lib test doc/assets/potato.min.js

# compiles coffee-script
%.js : %.coffee node_modules
	${BIN}/coffee -c $<

# minifies js
%.min.js : %.js node_modules
	${BIN}/uglifyjs -o $@ $< 

node_modules: package.json
	npm install

clean:
	rm -f ${JS_FILES}
	rm -fr node_modules
	rm -f doc/*.html
	rm -f examples/assets/*.js
	rm -f examples/assets/*.css

doc/assets/potato.min.js: potato.min.js
	cp potato.min.js doc/assets/potato.min.js

serve-doc:
	cd doc && ${BIN}/readymade serve

# build all lib files
lib: potato.js potato.min.js potato-browserify.js potato-browserify-min.js

potato.js: ${JS_FILES} node_modules
	${BIN}/browserify -e src/entry-point-browserify.js --outfile ./potato.js

potato-browserify.js: ${JS_FILES} node_modules
	${BIN}/browserify src/potato.js --outfile ./potato-browserify.js

# launch tests
test: ${JS_FILES} node_modules
	@npm test

