from django import template
from django.template.defaultfilters import stringfilter
from django.utils.safestring import mark_safe
from django.utils.html import escape
import re
from pygments import highlight
from pygments.formatters import HtmlFormatter
from pygments.lexers import get_lexer_by_name,guess_lexer, guess_lexer_for_filename, ClassNotFound

register = template.Library()

def get_lexer(value,arg):
    if arg is None:
        return guess_lexer(value)
    return guess_lexer_for_filename(arg,value) #get_lexer_by_name(arg)

@register.filter(name='highlight')
@stringfilter
def colorize(value, arg=None):
    try:
        return mark_safe(highlight(value,get_lexer(value,arg),HtmlFormatter()))
    except ClassNotFound:
        return mark_safe("<pre>%s</pre>" % escape(value))


@register.filter(name='highlight_table')
@stringfilter
def colorize_table(value,arg=None):
    try:
        return mark_safe(highlight(value,get_lexer(value,arg),HtmlFormatter(linenos='table')))
    except ClassNotFound:
        return mark_safe("<pre>%s</pre>" % escape(value))

rx_diff_pm = re.compile('^(?P<first_line>\d*</pre></div></td><td class="code"><div class="highlight"><pre>)?(?P<line>(<span class=".*?">)?(\+|-).*$)')     
rx_diff_questionmark = re.compile('(?P<line>(<span class=".*?">)?\?.*$)')     
rx_tag = re.compile('^(?P<tag>(<[^<]*>)*)(?P<rest>.*)')
@register.filter
def highlight_diff(value):
	"enclose highlighted lines beginning with an +-? in a span"
	result = ""
	prevline = None
	for line in value.splitlines(1):
		m1 = rx_diff_questionmark.match(line)
		if m1:
			# We have a ? line. Instead of printing it, we annotate the previous line with the markers, which can be -, ^ or +
			while line:
				# First strip all leading tags from both strings
				m2 = rx_tag.match(line)
				line = m2.group('rest')

				m2 = rx_tag.match(prevline)
				result += m2.group('tag')
				prevline = m2.group('rest')

				if not line or not prevline:
					result += prevline
					continue 
				if line[0] == '+':
					result += "<span class=\"addedChar\">%s</span>" % prevline[0]
				elif line[0] == '-':
					result += "<span class=\"deletedChar\">%s</span>" % prevline[0]
				elif line[0] == '^':
					result += "<span class=\"changedChar\">%s</span>" % prevline[0]
				else:
					result += prevline[0]
				line = line[1:]
				prevline = prevline[1:]
			prevline = None
		else:
			if prevline is not None:
				result += prevline
			m = rx_diff_pm.match(line)
			if m:
				if m.group('first_line'):
					result += m.group('first_line')
				prevline = "<div class='changed'>" + m.group('line') + "</div>"
			else:
				prevline = line
	if prevline is not None:
		result += prevline
	return mark_safe(result)
