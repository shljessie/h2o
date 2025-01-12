from django import template

register = template.Library()


@register.filter
def times(i):
    """
    For iterating an integer "i" number of times.
    Usage: {% for i in 5|times %}{{i}}{% endfor %}
    >> 01234
    """
    return range(i)
