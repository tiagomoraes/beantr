.PHONY: validate install-hermes install-claude install-opencode install-openclaw install-cowork uninstall uninstall-hermes uninstall-claude uninstall-opencode uninstall-openclaw uninstall-cowork package site-deploy preview-site

validate:
	python3 scripts/validate.py

install-hermes:
	./installers/install.sh hermes "$${BEANTR_LEDGER:-$$HOME/beantr}"

install-claude:
	./installers/install.sh claude-code "$${BEANTR_LEDGER:-$$HOME/beantr}"

install-opencode:
	./installers/install.sh opencode "$${BEANTR_LEDGER:-$$HOME/beantr}"

install-openclaw:
	./installers/install.sh openclaw "$${BEANTR_LEDGER:-$$HOME/beantr}"

install-cowork:
	./installers/install.sh cowork "$${BEANTR_LEDGER:-$$HOME/beantr}"

uninstall:
	./installers/uninstall.sh

uninstall-hermes:
	./installers/uninstall.sh hermes

uninstall-claude:
	./installers/uninstall.sh claude-code

uninstall-opencode:
	./installers/uninstall.sh opencode

uninstall-openclaw:
	./installers/uninstall.sh openclaw

uninstall-cowork:
	./installers/uninstall.sh cowork

package:
	mkdir -p dist
	git archive --format=tar.gz --prefix=beantr/ -o dist/beantr-agent-pack.tar.gz HEAD

site-deploy: package
	mkdir -p /home/hermes/artifacts/beantr
	cp -R site/. /home/hermes/artifacts/beantr/
	cp dist/beantr-agent-pack.tar.gz /home/hermes/artifacts/beantr/
	cp dist/beantr-agent-pack.tar.gz /home/hermes/artifacts/beantr/beantr-agent-pack-latest.tar.gz

preview-site:
	python3 -m http.server 8088 --directory site
