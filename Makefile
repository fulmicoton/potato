COFFEE_FILES=${shell find src -name "*.coffee"}
JS_FILES = $(COFFEE_FILES:.coffee=.js)
BIN=${shell npm bin}

%.js : %.coffee node_modules
	${BIN}/coffee -c $<


doc/assets/%.js : doc/markstrap/%.coffee node_modules
	${BIN}/coffee -c $< -o $@

doc/assets/%.css : doc/markstrap/%.less node_modules
	${BIN}/lessc $< $@

doc/%.html: %.md node_modules doc/assets/markstrap.jade
	${BIN}/markitup -t doc/assets/markstrap.jade -o doc/ $<

all: potato.js test potato-min.js potato-browserify.js potato-browserify-min.js examples

devenv: node_modules

node_modules: package.json
	npm install

clean: 
	rm -f ${JS_FILES}
	rm -fr node_modules
	rm -f doc/*.html

doc: doc/assets/markstrap.js doc/assets/markstrap.css doc/README.html

potato.js: ${JS_FILES} node_modules
	${BIN}/browserify -e src/entry-point-browserify.js --outfile ./potato.js

potato-browserify.js: ${JS_FILES} node_modules
	${BIN}/browserify src/potato.js --outfile ./potato-browserify.js

%-min.js : %.js node_modules
	${BIN}/uglifyjs -o $@ $< 

web: web/potato-browserify.js web/potato.js

test: ${JS_FILES} node_modules
	@npm test

#examples: web/potato.js node_modules
	# cd web/examples && find . -name "*.coffee" -exec ${BIN}/coffee -c {}  \;
	# ${BIN}/browserify  web/examples/example.js --ignore potato -o web/examples/example-browserified.js

# doc: dev
#	cd potato-doc && rm -fr build
#	cd potato-doc && lessc source/_static/basic.less > source/_static/basic.css
#	cd potato-doc && make html
#	docco potato/src/potato.coffee
