#!/usr/bin/env python
import sys

from markdown2 import markdown


template = open('TEMPLATE.html').read().decode('utf-8')


for file in sys.argv[1:]:
    new_file = file.partition('.md')[0] + '.html'
    print '%s -> %s' % (file, new_file)
    contents = open(file).read().decode('utf-8')
    html = markdown(contents, extras=['wiki-tables', 'markdown-in-html'])
    html = template.replace('{{body}}', html)
    open(new_file, 'w').write(html.encode('utf8'))
