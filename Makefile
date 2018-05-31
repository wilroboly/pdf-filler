include docker.mk

.PHONY: test

RUBY_VER ?= 2.3.3

test:
#	cd ./test/$(DRUPAL_VER) && PHP_VER=$(PHP_VER) ./run
