pip install virtualenv
pip install virtualenvwrapper

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export PIP_VIRTUALENV_BASE=$WORKON_HOME
source /usr/local/bin/virtualenvwrapper.sh

mkvirtualenv crawler
pip install -r requirements.txt

scrapy crawl NewsSpider -a src_json=sources/'Users/Jovial/Desktop/sample.json'